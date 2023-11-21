import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dieklingel_app/models/messages/session_message_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:path/path.dart';
import '../../../handlers/call.dart';
import '../../../models/home.dart';
import '../../../models/messages/candidate_message.dart';
import '../../../models/messages/close_message.dart';

class CallActiveViewModel extends ChangeNotifier {
  final Home home;
  final mqtt.Client connection;
  final Call call;
  final Completer<void> _onHangup = Completer();
  final String remoteSessionId;

  CallActiveViewModel({
    required this.home,
    required this.connection,
    required this.call,
    required this.remoteSessionId,
  }) {
    call.addListener(_onCallChange);

    connection.subscribe(
      "${home.username}/connections/candidate",
      (topic, message) {
        try {
          final payload = CandidateMessage.fromMap(json.decode(message));
          if (payload.header.sessionId != call.id) {
            return;
          }

          call.remoteIceCandidates.add(payload.body.iceCandidate);
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
          if (payload.header.sessionId != call.id) {
            return;
          }

          _onHangup.complete();
          await call.close();
        } catch (e) {
          log("could not parse the close message; message: $message, error: $e");
        }
      },
    );
  }

  void _onCallChange() {
    notifyListeners();
  }

  set isMicrophoneMuted(bool value) {
    Helper.setMicrophoneMute(
      value,
      call.renderer.srcObject!.getAudioTracks().first,
    );

    notifyListeners();
  }

  bool get isMicrophoneMuted {
    return false;
  }

  Future<void> onHangup() async {
    return _onHangup.future;
  }

  void hangup() {
    call.removeListener(_onCallChange);
    call.close();

    final payload = CloseMessage(
      header: SessionMessageHeader(
        senderDeviceId: home.username ?? "",
        senderSessionId: call.id,
        sessionId: remoteSessionId,
      ),
    );

    connection.publish(
      normalize("./${home.uri.path}/connections/close"),
      json.encode(payload.toMap()),
    );
    _onHangup.complete(null);
  }
}
