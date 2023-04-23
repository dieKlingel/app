import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import 'media_ressource.dart';
import 'microphone_state.dart';
import 'rtc_transceiver.dart';
import 'speaker_state.dart';

class RtcClientWrapper {
  MicrophoneState _microphoneState = MicrophoneState.muted;
  SpeakerState _speakerState = SpeakerState.muted;
  final MediaRessource ressource = MediaRessource();
  final RTCVideoRenderer renderer = RTCVideoRenderer();
  final List<IceServer> servers;
  final List<RtcTransceiver> transceivers;
  late final RTCPeerConnection connection;
  final _state = ValueNotifier<RTCPeerConnectionState>(
    RTCPeerConnectionState.RTCPeerConnectionStateDisconnected,
  );
  bool _isDisposed = false;

  void Function(SignalingMessage)? _onMessage;

  MicrophoneState get microphoneState => _microphoneState;

  set microphoneState(MicrophoneState state) {
    _microphoneState = state;
    _applyMicrophoneSettings();
  }

  SpeakerState get speakerState => _speakerState;

  set speakerState(SpeakerState state) {
    _speakerState = state;
    _applySpeakerSettings();
  }

  RtcClientWrapper._(this.servers, this.transceivers);

  ValueNotifier<RTCPeerConnectionState> get state => _state;

  static Future<RtcClientWrapper> create({
    List<IceServer> iceServers = const [],
    List<RtcTransceiver> transceivers = const [],
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    RtcClientWrapper wrapper = RtcClientWrapper._(iceServers, transceivers);
    await wrapper.renderer.initialize();

    List<Map<String, dynamic>> servers = iceServers
        .map(
          (e) => {
            "urls": e.urls,
            "username": e.username,
            "credential": e.credential
          },
        )
        .toList();

    Map<String, dynamic> configuration = {};
    configuration["iceServers"] = servers;
    configuration["sdpSemantics"] = "unified-plan";
    wrapper.connection = await createPeerConnection(configuration);

    wrapper.connection
      ..onIceCandidate = wrapper._onIceCandidate
      ..onConnectionState = wrapper._onConnectionState
      ..onTrack = wrapper._onTrack;

    for (RtcTransceiver transceiver in transceivers) {
      await wrapper.connection.addTransceiver(
        kind: transceiver.kind,
        init: RTCRtpTransceiverInit(direction: transceiver.direction),
      );
    }

    return wrapper;
  }

  void addMessage(SignalingMessage message) async {
    if (_isDisposed) {
      return;
    }
    switch (message.type) {
      case SignalingMessageType.offer:
        MediaStream? stream = ressource.stream;
        if (null != stream) {
          for (MediaStreamTrack track in stream.getTracks()) {
            connection.addTrack(track, stream);
          }
        }

        final remote = RTCSessionDescription(
          message.data["sdp"],
          message.data["type"],
        );

        await connection.setRemoteDescription(remote);
        final local = await connection.createAnswer();
        await connection.setLocalDescription(local);

        SignalingMessage answer = SignalingMessage()
          ..type = SignalingMessageType.answer
          ..data = local.toMap();

        _onMessage?.call(answer);
        break;
      case SignalingMessageType.answer:
        final description = RTCSessionDescription(
          message.data["sdp"],
          message.data["type"],
        );

        await connection.setRemoteDescription(description);
        break;
      case SignalingMessageType.candidate:
        final candidate = RTCIceCandidate(
          message.data["candidate"],
          message.data["sdpMid"],
          message.data["sdpMLineIndex"],
        );

        await connection.addCandidate(candidate);
        break;
      case SignalingMessageType.leave:
      case SignalingMessageType.busy:
      case SignalingMessageType.error:
        close();
        break;
    }
  }

  void onMessage(void Function(SignalingMessage) handler) {
    if (_isDisposed) {
      return;
    }
    _onMessage = handler;
  }

  Future<void> open() async {
    if (_isDisposed) {
      return;
    }
    RTCSessionDescription offer = await connection.createOffer();
    await connection.setLocalDescription(offer);

    MediaStream? stream = ressource.stream;
    if (null != stream) {
      for (MediaStreamTrack track in stream.getTracks()) {
        connection.addTrack(track, stream);
        Helper.setMicrophoneMute(true, track);
      }
    }

    _applyMicrophoneSettings();
    _applySpeakerSettings();

    SignalingMessage message = SignalingMessage();
    message.type = SignalingMessageType.offer;
    message.data = offer.toMap();

    _onMessage?.call(message);
  }

  Future<void> close() async {
    if (_isDisposed) {
      return;
    }
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.leave;

    await dispose();
    _onMessage?.call(message);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    ressource.close();
    await connection.close();
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.candidate
      ..data = candidate.toMap();

    _onMessage?.call(message);
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    _state.value = state;
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        close();
        break;
      default:
        break;
    }
  }

  void _onTrack(RTCTrackEvent event) {
    if (event.streams.isEmpty) {
      return;
    }
    _applyMicrophoneSettings();
    _applySpeakerSettings();

    renderer.srcObject = event.streams.first;
  }

  void _applyMicrophoneSettings() {
    switch (_microphoneState) {
      case MicrophoneState.muted:
        ressource.stream?.getAudioTracks().forEach((track) {
          Helper.setMicrophoneMute(true, track);
        });
        break;
      case MicrophoneState.unmuted:
        ressource.stream?.getAudioTracks().forEach((track) {
          Helper.setMicrophoneMute(false, track);
        });
        break;
    }
  }

  void _applySpeakerSettings() {
    switch (_speakerState) {
      case SpeakerState.muted:
        renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = false;
        });
        break;
      case SpeakerState.headphone:
        renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(false);
          }
        });
        break;
      case SpeakerState.speaker:
        renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(true);
          }
        });
        break;
    }
  }
}
