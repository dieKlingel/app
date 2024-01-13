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
import '../messages/message_header.dart';
import '../messages/offer_message.dart';
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
  RTCPeerConnection? _peer;
  bool _remoteTunnelAvailable = false;
  bool _firstTimeConnected = true;
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
      _onStateChanged();
    };
  }

  TunnelState get state {
    if (_peer != null && _remoteTunnelAvailable) {
      switch (_peer!.connectionState) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
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

  void send(String message) {
    switch (state) {
      case TunnelState.connected:
        if (_control.state == ConnectionState.connected) {
          // TODO: send over datachannel
          final prefix = uri.path.substring(1);
          _control.publish("$prefix/experimental/tunnel/relay/rpc", message);
        }
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

    await Future.wait([
      _peer?.close() ?? Future(() => null),
      Future.delayed(const Duration(milliseconds: 100)),
    ]);
    _peer = null;
    _remoteTunnelAvailable = false;
    _onStateChanged();

    _control.disconnect();
  }

  void _onStateChanged() async {
    onStateChanged?.call(state);

    switch (state) {
      case TunnelState.oneway:
        if (_peer != null) {
          await _peer?.close();
          return;
        }

        _control.publish(
          "$username/tunnel/state",
          jsonEncode({"online": true}),
          retain: true,
        );

        if (!_firstTimeConnected) {
          return;
        }
        _firstTimeConnected = false;

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

        break;
      case TunnelState.relayed:
        if (_peer != null) {
          return;
        }
        _peer = await createPeerConnection({
          "iceServers": iceServers.map((e) => e.toMap()).toList(),
          "sdpSemantics": "unified-plan",
        });

        // TODO: use correct and transceivers, transceivers are neccessary for the web to work (on iOS also works without)
        await _peer!.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.RecvOnly,
          ),
        );
        await _peer!.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        );

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
        break;

      case TunnelState.connected:
      case TunnelState.connecting:
      case TunnelState.disconnected:
        break;
    }
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
