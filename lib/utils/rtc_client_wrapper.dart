import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/ice_server.dart';
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
  final String uuid;
  final List<RtcTransceiver> transceivers;
  late final RTCPeerConnection connection;
  final _state = ValueNotifier<RTCPeerConnectionState>(
    RTCPeerConnectionState.RTCPeerConnectionStateDisconnected,
  );
  bool _isDisposed = false;
  final List<RTCIceCandidate> _candiateBuffer = [];
  bool _remoteDescriptionSet = false;
  RTCSessionDescription? _offer;
  RTCSessionDescription? _answer;

  void Function(RTCIceCandidate)? _onIceCandidateCallback;

  Future<RTCSessionDescription> offer() async {
    if (_isDisposed) {
      throw Exception(
        "cannot create an offer after the connection has been disposed",
      );
    }
    if (_offer == null) {
      _offer = await connection.createOffer();
      await connection.setLocalDescription(_offer!);
    }
    return _offer!;
  }

  Future<void> setRemoteDescription(RTCSessionDescription answer) async {
    if (_remoteDescriptionSet) {
      throw "remote already set";
    }
    _remoteDescriptionSet = true;
    await connection.setRemoteDescription(answer);
    for (var candidate in _candiateBuffer) {
      print("add buffered candidate");
      connection.addCandidate(candidate);
    }
    _candiateBuffer.clear();
  }

  Future<RTCSessionDescription> answer(RTCSessionDescription offer) async {
    if (_isDisposed) {
      throw Exception(
        "cannot create an answer after the connection has been disposed",
      );
    }
    if (_answer == null) {
      await connection.setRemoteDescription(offer);
      _answer = await connection.createAnswer();
    }
    return _answer!;
  }

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

  RtcClientWrapper._(this.servers, this.transceivers, this.uuid);

  ValueNotifier<RTCPeerConnectionState> get state => _state;

  static Future<RtcClientWrapper> create({
    List<IceServer> iceServers = const [],
    List<RtcTransceiver> transceivers = const [],
    required String uuid,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    RtcClientWrapper wrapper = RtcClientWrapper._(
      iceServers,
      transceivers,
      uuid,
    );
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
      ..onIceCandidate = (RTCIceCandidate candidate) {
        wrapper._onIceCandidateCallback?.call(candidate);
      }
      ..onConnectionState = wrapper._onConnectionState
      ..onTrack = wrapper._onTrack;

    wrapper.renderer.onFirstFrameRendered = () {
      print("frame");
    };

    for (RtcTransceiver transceiver in transceivers) {
      await wrapper.connection.addTransceiver(
        kind: transceiver.kind,
        init: RTCRtpTransceiverInit(direction: transceiver.direction),
      );
    }

    return wrapper;
  }

  void addIceCandidate(RTCIceCandidate candidate) async {
    if (_isDisposed) {
      return;
    }
    if (_remoteDescriptionSet) {
      await connection.addCandidate(candidate);
    } else {
      _candiateBuffer.add(candidate);
    }
  }

  void onIceCandidate(void Function(RTCIceCandidate) handler) {
    if (_isDisposed) {
      return;
    }
    _onIceCandidateCallback = handler;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    ressource.close();
    await connection.close();
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    _state.value = state;
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        print("close connection");
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

  void _applySpeakerSettings() async {
    final streams = connection.getRemoteStreams();
    for (final stream in streams) {
      if (stream == null) {
        continue;
      }
      switch (_speakerState) {
        case SpeakerState.muted:
          stream.getAudioTracks().forEach((track) {
            track.enabled = false;
          });
          break;
        case SpeakerState.headphone:
          stream.getAudioTracks().forEach((track) {
            track.enabled = true;
            if (!kIsWeb) {
              track.enableSpeakerphone(false);
            }
          });
          break;
        case SpeakerState.speaker:
          stream.getAudioTracks().forEach((track) {
            track.enabled = true;
            if (!kIsWeb) {
              track.enableSpeakerphone(false);
            }
          });
          break;
      }
    }
  }
}
