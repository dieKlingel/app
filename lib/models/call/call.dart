import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../utils/media_ressource.dart';
import '../audio/microphone_state.dart';
import '../audio/speaker_state.dart';
import '../ice_server.dart';

class Call {
  final String id;
  final List<IceServer> iceServers;
  final renderer = RTCVideoRenderer();
  final _localIceCandidates = StreamController<RTCIceCandidate>();
  final _remoteIceCandidates = StreamController<RTCIceCandidate>();
  final _connectionState = StreamController<RTCPeerConnectionState>();
  final _media = MediaRessource();

  RTCPeerConnection? connection;
  SpeakerState _speaker = SpeakerState.muted;
  MicrophoneState _microphone = MicrophoneState.muted;

  Call(
    this.id,
    this.iceServers,
  ) {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && Platform.isIOS) {
      Helper.setAppleAudioIOMode(AppleAudioIOMode.localAndRemote);
    }
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
    for (final track in remoteAudioTracks) {
      switch (_speaker) {
        case SpeakerState.muted:
          track.enabled = false;
          break;
        case SpeakerState.earphone:
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(false);
          }
          break;
        case SpeakerState.speaker:
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(true);
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
        if (event.track.kind == "audio") {
          switch (_speaker) {
            case SpeakerState.muted:
              event.track.enabled = false;
              break;
            case SpeakerState.earphone:
              event.track.enabled = true;
              if (!kIsWeb) {
                event.track.enableSpeakerphone(false);
              }
              break;
            case SpeakerState.speaker:
              event.track.enabled = true;
              if (!kIsWeb) {
                event.track.enableSpeakerphone(true);
              }
              break;
          }
        }
        renderer.srcObject = event.streams.first;
      }
      ..onConnectionState = (state) {
        _connectionState.add(state);
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
    _media.close();
    _localIceCandidates.close();
    _remoteIceCandidates.close();
    renderer.dispose();
  }
}
