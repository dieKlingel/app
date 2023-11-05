import 'dart:convert';

import 'package:dieklingel_app/handlers/call.dart';
import 'package:dieklingel_app/handlers/call_kit.dart';
import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/messages/answer_message.dart';
import 'package:dieklingel_app/models/messages/candidate_message.dart';
import 'package:dieklingel_app/models/messages/candidate_message_body.dart';
import 'package:dieklingel_app/models/messages/close_message.dart';
import 'package:dieklingel_app/models/messages/message_header.dart';
import 'package:dieklingel_app/models/messages/offer_message.dart';
import 'package:dieklingel_app/models/messages/session_message_body.dart';
import 'package:dieklingel_app/models/messages/session_message_header.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class CallViewModel extends ChangeNotifier {
  final HiveHome home;
  final MqttClient client;
  final IceServerRepository iceServerRepository;

  String _remoteSessionId = "";
  String _localSessionId = "";

  CallViewModel(this.home, this.client, this.iceServerRepository) {
    client.subscribe(
      "${home.username}/connections/answer",
      (topic, message) async {
        try {
          final payload = AnswerMessage.fromMap(json.decode(message));
          _remoteSessionId = payload.header.senderSessionId;
          final call = CallKit.calls[payload.header.sessionId];
          if (call == null) {
            print("answer without call");
            return;
          }

          await call.withRemoteAnswer(payload.body.sessionDescription);
        } catch (e) {
          print(e);
        }
      },
    );

    client.subscribe(
      "${home.username}/connections/candidate",
      (topic, message) {
        try {
          final payload = CandidateMessage.fromMap(json.decode(message));
          final call = CallKit.calls[_localSessionId];
          if (call == null) {
            print("candidate without call");
            return;
          }

          call.remoteIceCandidates.add(payload.body.iceCandidate);
        } catch (e) {
          print(e);
        }
      },
    );

    client.subscribe(
      "${home.username}/connections/close",
      (topic, message) async {
        try {
          final payload = CloseMessage.fromMap(json.decode(message));
          final call = CallKit.calls[payload.header.sessionId];
          if (call == null) {
            print("close without call");
            return;
          }

          await call.close();
          CallKit.calls.remove(payload.header.sessionId);
          _localSessionId = "";
          _remoteSessionId = "";
        } catch (e) {
          print(e);
        }
      },
    );
  }

  bool get isInCall {
    return CallKit.calls[_localSessionId] != null;
  }

  RTCVideoRenderer? get renderer {
    return CallKit.calls[_localSessionId]?.renderer;
  }

  void dial() async {
    _localSessionId = const Uuid().v4();
    final call = Call(_localSessionId, iceServerRepository.servers);
    call.addListener(() {
      notifyListeners();
    });
    CallKit.calls[_localSessionId] = call;
    notifyListeners();

    final offer = await call.offer();
    final payload = OfferMessage(
      header: MessageHeader(
        senderDeviceId: home.username ?? "",
        senderSessionId: call.id,
      ),
      body: SessionMessageBody(
        sessionDescription: offer,
      ),
    );

    client.publish(
      normalize("./${home.uri.path}/connections/offer"),
      json.encode(payload.toMap()),
    );

    call.localIceCandidates.listen((candidate) {
      final payload = CandidateMessage(
        header: SessionMessageHeader(
          senderDeviceId: home.username ?? "",
          senderSessionId: _localSessionId,
          sessionId: _remoteSessionId,
        ),
        body: CandidateMessageBody(
          iceCandidate: candidate,
        ),
      );

      client.publish(
        normalize("./${home.uri.path}/connections/candidate"),
        json.encode(payload.toMap()),
      );
    });
  }

  void hangup() async {
    final call = CallKit.calls[_localSessionId];
    if (call == null) {
      return;
    }
    final payload = CloseMessage(
      header: SessionMessageHeader(
        senderDeviceId: home.username ?? "",
        senderSessionId: call.id,
        sessionId: _remoteSessionId,
      ),
    );

    await call.close();
    CallKit.calls.remove(_localSessionId);
    _localSessionId = "";
    _remoteSessionId = "";
    notifyListeners();

    client.publish(
      normalize("./${home.uri.path}/connections/close"),
      json.encode(payload.toMap()),
    );
  }
}
