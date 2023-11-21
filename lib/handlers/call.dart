import 'dart:async';

import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:flutter/foundation.dart';

import '../models/audio/speaker_state.dart';
import '../models/ice_server.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Call extends ChangeNotifier {
  final String id;
  final List<IceServer> iceServers;
  final RTCVideoRenderer renderer = RTCVideoRenderer();
  final StreamController<RTCIceCandidate> _localIceCandidates =
      StreamController();
  final StreamController<RTCIceCandidate> _remoteIceCandidates =
      StreamController();

  RTCPeerConnection? connection;
  SpeakerState _speaker = SpeakerState.muted;
  MicrophoneState _microphone = MicrophoneState.muted;

  Call(
    this.id,
    this.iceServers,
  ) {
    WidgetsFlutterBinding.ensureInitialized();
    _remoteIceCandidates.stream.listen((event) {
      connection!.addCandidate(event);
    });
  }

  List<MediaStreamTrack> get loaclAudioTracks {
    final conn = connection;
    if (conn == null) {
      return [];
    }

    final List<MediaStreamTrack> tracks = conn
        .getLocalStreams()
        .whereType<MediaStream>()
        .expand<MediaStreamTrack>(
          (stream) => stream.getAudioTracks(),
        )
        .toList();
    return tracks;
  }

  List<MediaStreamTrack> get remoteAudioTracks {
    final conn = connection;
    if (conn == null) {
      return [];
    }

    final List<MediaStreamTrack> tracks = conn
        .getRemoteStreams()
        .whereType<MediaStream>()
        .expand<MediaStreamTrack>(
          (stream) => stream.getAudioTracks(),
        )
        .toList();
    return tracks;
  }

  SpeakerState get speaker {
    return _speaker;
  }

  set speaker(SpeakerState state) {
    _speaker = state;
    notifyListeners();
    for (final track in remoteAudioTracks) {
      switch (_speaker) {
        case SpeakerState.muted:
          track.enabled = false;
          break;
        case SpeakerState.earphone:
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(true);
          }
          break;
        case SpeakerState.speaker:
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(false);
          }
          break;
      }
    }
  }

  MicrophoneState get microphone {
    return _microphone;
  }

  set microphone(MicrophoneState state) {
    _microphone = state;
    notifyListeners();
    for (final track in loaclAudioTracks) {
      switch (_microphone) {
        case MicrophoneState.muted:
          track.enabled = false;
          break;
        case MicrophoneState.unmuted:
          track.enabled = true;
          break;
      }
    }
  }

  Future<RTCSessionDescription> offer() async {
    await renderer.initialize();

    connection = await createPeerConnection({
      "iceServers": iceServers.map((e) => e.toMap()).toList(),
      "sdpSemantics": "unified-plan",
    });

    connection!
      ..onIceCandidate = (candidate) {
        _localIceCandidates.add(candidate);
      }
      ..onTrack = (event) {
        if (event.streams.isEmpty) {
          return;
        }

        for (final track in event.streams.first.getAudioTracks()) {
          // TODO:set speaker
          // track.enabled = !_isSpeakerMuted;
        }

        renderer.srcObject = event.streams.first;
      }
      ..onConnectionState = (state) {
        notifyListeners();
      };

    await connection!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    );
    await connection!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    final offer = await connection!.createOffer();
    await connection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> withRemoteAnswer(RTCSessionDescription answer) async {
    await connection!.setRemoteDescription(answer);
  }

  RTCPeerConnectionState get state {
    final connectionState = connection?.connectionState;
    if (connectionState == null) {
      return RTCPeerConnectionState.RTCPeerConnectionStateClosed;
    }

    return connectionState;
  }

  Stream<RTCIceCandidate> get localIceCandidates {
    return _localIceCandidates.stream;
  }

  Sink<RTCIceCandidate> get remoteIceCandidates {
    return _remoteIceCandidates.sink;
  }

  Future<void> close() async {
    _localIceCandidates.close();
    _remoteIceCandidates.close();
    renderer.dispose();
  }
}
