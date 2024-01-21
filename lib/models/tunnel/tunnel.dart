import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:uuid/uuid.dart';

import '../ice_server.dart';
import '../messages/answer_message.dart';
import '../messages/candidate_message.dart';
import '../messages/candidate_message_body.dart';
import '../messages/close_message.dart';
import '../messages/session_message_body.dart';
import '../messages/session_message_header.dart';
import '../../components/stream_subscription_mixin.dart';
import 'tunnel_state.dart';

class Tunnel with StreamHandlerMixin {
  final List<IceServer> iceServers;
  final Uri uri;
  final Client _control;
  final String username;
  final String password;
  final StreamController<String> _messages = StreamController.broadcast();

  late final String sessionId = const Uuid().v4();
  TunnelState _state = TunnelState.disconnected;
  RTCPeerConnection? _peer;
  RTCDataChannel? _channel;
  bool _remoteTunnelAvailable = false;
  String _remoteSessionId = "";
  void Function(TunnelState)? onStateChanged;
  void Function(MediaStream)? onVideoTrackReceived;
  void Function(MediaStream)? onAudioTrackReceived;

  Tunnel(
    this.uri, {
    required this.username,
    required this.password,
    this.iceServers = const [],
  }) : _control = Client(uri) {
    _control.onConnectionStateChanged = (_) {
      _onStateChanged();
    };
  }

  TunnelState get state {
    if (_channel != null && _remoteTunnelAvailable) {
      switch (_channel!.state) {
        case RTCDataChannelState.RTCDataChannelOpen:
          return TunnelState.connected;
        default:
          break;
      }
    }

    switch (_control.state) {
      case ConnectionState.connected:
        if (_remoteTunnelAvailable) {
          return TunnelState.relayed;
        }
        return TunnelState.oneway;
      case ConnectionState.connecting:
        return TunnelState.connecting;
      default:
        break;
    }

    return TunnelState.disconnected;
  }

  RTCPeerConnection? get connection {
    return _peer;
  }

  Future<void> connect() async {
    _control.disconnect();
    await _peer?.close();
    _peer = null;
    _onStateChanged();

    await _control.connect(
      username: username,
      password: password,
      throws: false,
      disconnectMessage: DisconnectMessage(
        "$username/tunnel/state",
        jsonEncode({"online": false}),
        retain: true,
      ),
    );
  }

  Future<void> send(String message) async {
    switch (state) {
      case TunnelState.connected:
        await _channel!.send(RTCDataChannelMessage(message));
        break;
      case TunnelState.relayed:
        final prefix = uri.path.substring(1);
        _control.publish("$prefix/experimental/tunnel/relay/rpc", message);
        break;
      default:
        throw Exception("cannot send a message if not connected or relayed");
    }
  }

  Stream<String> get messages {
    return _messages.stream;
  }

  Future<void> disconnect() async {
    if (_control.state == ConnectionState.connected) {
      _control.publish(
        "$username/tunnel/state",
        jsonEncode({"online": false}),
        retain: true,
      );
    }

    if (_peer != null && _remoteSessionId.isNotEmpty) {
      final prefix = uri.path.substring(1);
      _control.publish(
        "$prefix/connections/close",
        jsonEncode(
          CloseMessage(
            header: SessionMessageHeader(
                senderDeviceId: username,
                sessionId: _remoteSessionId,
                senderSessionId: sessionId),
          ).toMap(),
        ),
      );
    }

    await Future.wait([
      _peer?.close() ?? Future(() => null),
      Future.delayed(const Duration(milliseconds: 100)),
    ]);
    _peer = null;
    _remoteSessionId = "";
    _remoteTunnelAvailable = false;
    _onStateChanged();

    _control.disconnect();
  }

  void _onStateChanged() async {
    final previousState = _state;
    final currentState = state;
    _state = currentState;
    if (previousState == currentState) {
      return;
    }

    onStateChanged?.call(currentState);

    // state changes are as following
    // disconnected -> connecting -> [oneway] -> [relayed] -> connected
    if ([
          TunnelState.disconnected,
          TunnelState.connecting,
        ].contains(previousState) &&
        [
          TunnelState.oneway,
          TunnelState.relayed,
          TunnelState.connected,
        ].contains(currentState)) {
      _onSetupSubscriptions();
    } else if ([
          TunnelState.oneway,
          TunnelState.relayed,
          TunnelState.connected,
        ].contains(previousState) &&
        [
          TunnelState.disconnected,
          TunnelState.connecting,
        ].contains(currentState)) {
      await _onDisposeSubscriptions();
    }

    if ([
          TunnelState.disconnected,
          TunnelState.connecting,
          TunnelState.oneway,
        ].contains(previousState) &&
        [TunnelState.relayed].contains(currentState)) {
      await _onSetupPeerConnection();
    } else if ([
          TunnelState.relayed,
          TunnelState.connected,
        ].contains(previousState) &&
        [
          TunnelState.disconnected,
          TunnelState.connecting,
          TunnelState.oneway,
        ].contains(currentState)) {
      await _onDisposePeerConnection();
    }
  }

  void _onSetupSubscriptions() {
    _control.publish(
      "$username/tunnel/state",
      jsonEncode({"online": true}),
      retain: true,
    );

    streams.subscribe(
      _control.topic("$username/connections/answer"),
      (event) {
        final (_, message) = event;
        final payload = AnswerMessage.fromMap(jsonDecode(message));
        _onConnectionAnswer(payload);
      },
    );

    streams.subscribe(_control.topic("$username/connections/renegotiation"),
        (event) {
      final (_, message) = event;
      final payload = AnswerMessage.fromMap(jsonDecode(message));
      _onConnectionRenegotiation(payload);
    });

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

    final prefix = uri.path.substring(1);
    streams.subscribe(
      _control.topic("$prefix/tunnel/state"),
      (event) {
        final (_, message) = event;
        final payload = jsonDecode(message);
        if (payload["online"] is! bool) {
          return;
        }
        if (_remoteTunnelAvailable == payload["online"]) {
          return;
        }
        _remoteTunnelAvailable = payload["online"];
        _onStateChanged();
      },
    );

    streams.subscribe(
      _control.topic("$prefix/experimental/tunnel/relay/rpc/response"),
      (event) {
        final (_, message) = event;
        _messages.add(message);
      },
    );
  }

  Future<void> _onDisposeSubscriptions() async {
    await streams.dispose();
  }

  Future<void> _onSetupPeerConnection() async {
    _peer = await createPeerConnection({
      "iceServers": iceServers.map((e) => e.toMap()).toList(),
      "sdpSemantics": "unified-plan",
    });

    _peer!.onConnectionState = (_) => _onStateChanged();
    _peer!.onIceConnectionState = (_) => _onStateChanged();
    _peer!.onIceGatheringState = (_) => _onStateChanged();
    _peer!.onSignalingState = (_) => _onStateChanged();

    _peer!.onTrack = (event) {
      _onStateChanged();
      if (event.track.kind == "video") {
        onVideoTrackReceived?.call(event.streams.first);
      }
      if (event.track.kind == "audio") {
        onAudioTrackReceived?.call(event.streams.first);
      }
    };

    _peer!.onRenegotiationNeeded = () async {
      final peer = _peer!;
      final offer = await peer.createOffer();
      await peer.setLocalDescription(offer);

      final prefix = uri.path.substring(1);
      final channel = _remoteSessionId.isEmpty ? "offer" : "renegotiation";
      _control.publish(
        "$prefix/connections/$channel",
        jsonEncode(
          AnswerMessage(
            header: SessionMessageHeader(
              senderDeviceId: username,
              senderSessionId: sessionId,
              sessionId: _remoteSessionId,
            ),
            body: SessionMessageBody(
              sessionDescription: offer,
            ),
          ).toMap(),
        ),
      );
    };

    _peer!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    final prefix = uri.path.substring(1);
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

    _channel = await _peer!.createDataChannel(
      "tunnel",
      RTCDataChannelInit(),
    );
    _channel!.onMessage = (message) {
      if (message.isBinary) {
        return;
      }

      _messages.add(message.text);
    };
    _channel!.onDataChannelState = (_) => _onStateChanged();
  }

  Future<void> _onDisposePeerConnection() async {
    await _channel?.close();
    _channel = null;
    await _peer?.close();
    await _peer?.dispose();
    _peer = null;
  }

  void _onConnectionRenegotiation(AnswerMessage message) async {
    if (message.header.sessionId != sessionId) {
      return;
    }

    if (_peer!.signalingState != RTCSignalingState.RTCSignalingStateStable) {
      await Future.wait([
        _peer!.setLocalDescription(RTCSessionDescription(null, "rollback")),
        _peer!.setRemoteDescription(message.body.sessionDescription),
      ]);
    } else {
      await _peer!.setRemoteDescription(message.body.sessionDescription);
    }

    final answer = await _peer!.createAnswer();
    await _peer!.setLocalDescription(answer);

    final prefix = uri.path.substring(1);
    _control.publish(
      "$prefix/connections/answer",
      jsonEncode(
        AnswerMessage(
          header: SessionMessageHeader(
            senderDeviceId: username,
            senderSessionId: sessionId,
            sessionId: _remoteSessionId,
          ),
          body: SessionMessageBody(
            sessionDescription: answer,
          ),
        ).toMap(),
      ),
    );
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
    await _messages.close();
    await streams.dispose();
  }
}
