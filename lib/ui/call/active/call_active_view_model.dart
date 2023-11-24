import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dieklingel_app/components/stream_subscription_mixin.dart';
import 'package:dieklingel_app/models/audio/speaker_state.dart';
import 'package:dieklingel_app/models/messages/candidate_message_body.dart';
import 'package:dieklingel_app/models/messages/session_message_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:path/path.dart';
import '../../../models/audio/microphone_state.dart';
import '../../../models/call/call.dart';
import '../../../models/home.dart';
import '../../../models/messages/candidate_message.dart';
import '../../../models/messages/close_message.dart';

class CallActiveViewModel extends ChangeNotifier with StreamHandlerMixin {
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
    streams.subscribe(
      connection.topic("${home.username}/connections/candidate"),
      (event) {
        final (_, message) = event;
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

    streams.subscribe(connection.topic("${home.username}/connections/close"),
        (event) async {
      final (_, message) = event;

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
    });

    streams.subscribe(call.localIceCandidates, (candidate) {
      final payload = CandidateMessage(
        header: SessionMessageHeader(
          senderDeviceId: home.username!,
          sessionId: remoteSessionId,
          senderSessionId: call.id,
        ),
        body: CandidateMessageBody(iceCandidate: candidate),
      );

      connection.publish(
        normalize("./${home.uri.path}/connections/candidate"),
        json.encode(payload.toMap()),
      );
    });

    call.renderer.addListener(() {
      notifyListeners();
    });

    call.renderer.onFirstFrameRendered = () {
      // BUG: this method gets not called on web
      log("the first frame of the video was renderd");
      notifyListeners();
    };
  }

  set microphone(MicrophoneState state) {
    call.microphone = state;
    notifyListeners();
  }

  MicrophoneState get microphone {
    return call.microphone;
  }

  set speaker(SpeakerState state) {
    call.speaker = state;
    notifyListeners();
  }

  SpeakerState get speaker {
    return call.speaker;
  }

  RTCVideoRenderer get renderer {
    return call.renderer;
  }

  Future<void> onHangup() async {
    return _onHangup.future;
  }

  void hangup() {
    streams.dispose();
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

  @override
  void dispose() {
    streams.dispose();
    super.dispose();
  }
}
