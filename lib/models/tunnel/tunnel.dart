import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:uuid/uuid.dart';

import 'tunnel_state.dart';
import '../ice_server.dart';
import '../messages/answer_message.dart';
import '../messages/candidate_message.dart';
import '../messages/candidate_message_body.dart';
import '../messages/close_message.dart';
import '../messages/message_header.dart';
import '../messages/offer_message.dart';
import '../messages/session_message_body.dart';
import '../messages/session_message_header.dart';
import '../../components/stream_subscription_mixin.dart';

class Tunnel with StreamHandlerMixin {
  final List<IceServer> iceServers;
  final Uri uri;
  final Client _control;
  final String username;
  final String password;

  late final String sessionId = const Uuid().v4();
  RTCPeerConnection? _peer;

  String _remoteSessionId = "";
  void Function(TunnelState)? onStateChanged;
  void Function(MediaStream)? onVideoTrackReceived;

  Tunnel(
    this.uri, {
    required this.username,
    required this.password,
    this.iceServers = const [],
  }) : _control = Client(uri) {
    _control.onConnectionStateChanged = (_) {
      onStateChanged?.call(state);
    };
  }

  TunnelState get state {
    return TunnelState.from(
      control: _control,
      peer: _peer,
    );
  }

  Future<void> connect() async {
    _control.disconnect();
    await _peer?.close();

    await _control.connect(
      username: username,
      password: password,
      throws: false,
    );

    if (_control.state != ConnectionState.connected) {
      return;
    }

    streams.subscribe(
      _control.topic("$username/connections/answer"),
      (event) {
        final (_, message) = event;
        final payload = AnswerMessage.fromMap(jsonDecode(message));
        _onConnectionAnswer(payload);
      },
    );

    streams.subscribe(
      _control.topic("$username/connections/candidate"),
      (event) {
        final (_, message) = event;
        final payload = CandidateMessage.fromMap(jsonDecode(message));
        _onConnectionCandidate(payload);
      },
    );

    streams.subscribe(
      _control.topic("$username/connections/close"),
      (event) {
        final (_, message) = event;
        final payload = CloseMessage.fromMap(jsonDecode(message));
        _onConnectionClose(payload);
      },
    );

    _peer = await createPeerConnection({
      "iceServers": iceServers.map((e) => e.toMap()).toList(),
      "sdpSemantics": "unified-plan",
    });

    _peer!.onConnectionState = (_) {
      onStateChanged?.call(state);
    };

    _peer!.onTrack = (event) {
      if (event.track.kind == "video") {
        onVideoTrackReceived?.call(event.streams.first);
      }
      if (event.track.kind == "audio") {
        // TODO: handle audio track
      }
    };

    final offer = await _peer!.createOffer();
    await _peer!.setLocalDescription(offer);

    final prefix = uri.path.substring(1);
    _control.publish(
      "$prefix/connections/offer",
      jsonEncode(
        OfferMessage(
          header: MessageHeader(
            senderDeviceId: username,
            senderSessionId: sessionId,
          ),
          body: SessionMessageBody(
            sessionDescription: offer,
          ),
        ).toMap(),
      ),
    );

    _peer!.onIceCandidate = (candidate) {
      _control.publish(
        "$prefix/connections/candidate",
        jsonEncode(
          CandidateMessage(
            header: SessionMessageHeader(
              senderDeviceId: username,
              sessionId: _remoteSessionId,
              senderSessionId: sessionId,
            ),
            body: CandidateMessageBody(
              iceCandidate: candidate,
            ),
          ).toMap(),
        ),
      );
    };

    _peer!.onRenegotiationNeeded = () {
      // TODO: resend offer
    };
  }

  Future<void> disconnect() async {
    await _peer?.close();
    _control.disconnect();
  }

  void _onConnectionAnswer(AnswerMessage message) {
    if (message.header.sessionId != sessionId) {
      return;
    }

    _remoteSessionId = message.header.senderSessionId;
    _peer!.setRemoteDescription(message.body.sessionDescription);
  }

  void _onConnectionCandidate(CandidateMessage message) {
    if (message.header.sessionId != sessionId) {
      return;
    }

    _peer!.addCandidate(message.body.iceCandidate);
  }

  void _onConnectionClose(CloseMessage message) {
    if (message.header.sessionId != sessionId) {
      return;
    }

    _peer!.close();
  }

  Future<void> dispose() async {
    await disconnect();
    await streams.dispose();
  }
}
