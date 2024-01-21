import 'package:dieklingel_app/models/audio/microphone_state.dart';
import 'package:dieklingel_app/models/audio/speaker_state.dart';
import 'package:dieklingel_app/utils/media_ressource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallViewModel extends ChangeNotifier {
  final RTCVideoRenderer renderer;
  final RTCPeerConnection connection;
  final MediaRessource _media = MediaRessource();

  MicrophoneState _microphone = MicrophoneState.muted;
  SpeakerState _speaker = SpeakerState.muted;

  CallViewModel({
    required this.renderer,
    required this.connection,
  }) {
    _init();
  }

  Future<void> _init() async {
    final stream = await _media.open(true, false);
    final track = stream?.getAudioTracks().firstOrNull;
    if (track == null) {
      return;
    }

    await connection.addTrack(track, stream!);
    track.enabled = false;
  }

  MicrophoneState get microphone {
    return _microphone;
  }

  set microphone(MicrophoneState state) {
    _microphone = state;
    final List<MediaStreamTrack> tracks = _media.stream?.getAudioTracks() ?? [];

    for (final track in tracks) {
      switch (_microphone) {
        case MicrophoneState.muted:
          track.enabled = false;
          break;
        case MicrophoneState.unmuted:
          track.enabled = true;
          break;
      }
    }
    notifyListeners();
  }

  SpeakerState get speaker {
    return _speaker;
  }

  set speaker(SpeakerState state) {
    _speaker = state;
    List<MediaStreamTrack> tracks = connection
        .getRemoteStreams()
        .whereType<MediaStream>()
        .expand<MediaStreamTrack>(
          (stream) => stream.getAudioTracks(),
        )
        .toList();
    for (final track in tracks) {
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
    notifyListeners();
  }

  @override
  void dispose() {
    _media.close();
    super.dispose();
  }
}
