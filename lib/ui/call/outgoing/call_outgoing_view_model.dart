import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../../handlers/call.dart';
import '../../../models/home.dart';
import '../../../models/messages/answer_message.dart';
import '../../../models/messages/candidate_message.dart';
import '../../../models/messages/close_message.dart';
import '../../../models/messages/message_header.dart';
import '../../../models/messages/offer_message.dart';
import '../../../models/messages/session_message_body.dart';

class CallOutgoingViewModel extends ChangeNotifier {
  final IceServerRepository iceServerRepository;
  final Home home;
  final mqtt.Client connection;
  final Completer<void> _onHangup = Completer();
  final Completer<(Call, String)> _onAnswer = Completer();
  Timer? _timeout;

  late final Call _call = Call(const Uuid().v4(), iceServerRepository.servers);

  CallOutgoingViewModel({
    required this.home,
    required this.connection,
    required this.iceServerRepository,
  }) {
    connection.subscribe(
      "${home.username}/connections/answer",
      (topic, message) async {
        try {
          final payload = AnswerMessage.fromMap(json.decode(message));
          if (payload.header.sessionId != _call.id) {
            return;
          }

          _timeout?.cancel();
          _onAnswer.complete((_call, payload.header.senderSessionId));
          await _call.withRemoteAnswer(payload.body.sessionDescription);
        } catch (e) {
          log("could not parse the answer message; message: $message, error: $e");
        }
      },
    );

    connection.subscribe(
      "${home.username}/connections/candidate",
      (topic, message) {
        try {
          final payload = CandidateMessage.fromMap(json.decode(message));
          if (payload.header.sessionId != _call.id) {
            return;
          }

          _call.remoteIceCandidates.add(payload.body.iceCandidate);
        } catch (e) {
          log("could not parse the candidate message; message: $message, error: $e");
        }
      },
    );

    connection.subscribe(
      "${home.username}/connections/close",
      (topic, message) async {
        try {
          final payload = CloseMessage.fromMap(json.decode(message));
          if (payload.header.sessionId != _call.id) {
            return;
          }

          await _call.close();
          _onHangup.complete(null);
        } catch (e) {
          log("could not parse the close message; message: $message, error: $e");
        }
      },
    );
  }

  Future<void> onHangup() {
    return _onHangup.future;
  }

  Future<(Call, String)> onAnswer() {
    return _onAnswer.future;
  }

  Future<void> call() async {
    if (_timeout != null) {
      throw Exception("a call was already in progress");
    }

    final offer = await _call.offer();
    final payload = OfferMessage(
      header: MessageHeader(
        senderDeviceId: home.username ?? "",
        senderSessionId: _call.id,
      ),
      body: SessionMessageBody(
        sessionDescription: offer,
      ),
    );

    connection.publish(
      normalize("./${home.uri.path}/connections/offer"),
      json.encode(payload.toMap()),
    );
    _timeout = Timer(
      const Duration(seconds: 15),
      () => _onHangup.complete(),
    );
  }

  void hangup() {
    _call.close();
    _onHangup.complete();
  }
}
