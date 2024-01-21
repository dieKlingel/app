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
  MediaStreamTrack? _track;

  CallViewModel({
    required this.renderer,
    required this.connection,
  }) {
    _init();
  }

  Future<void> _init() async {
    final stream = await _media.open(true, false);
    _track = stream?.getAudioTracks().firstOrNull;
    if (_track == null) {
      return;
    }

    await connection.addTrack(_track!, stream!);
    await Helper.setMicrophoneMute(true, _track!);
  }

  MicrophoneState get microphone {
    return _microphone;
  }

  set microphone(MicrophoneState state) {
    if (_track == null) {
      _microphone = MicrophoneState.muted;
    } else {
      _microphone = state;
    }

    switch (_microphone) {
      case MicrophoneState.muted:
        Helper.setMicrophoneMute(true, _track!);
        break;
      case MicrophoneState.unmuted:
        Helper.setMicrophoneMute(false, _track!);
        break;
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
    speaker = SpeakerState.muted;
    microphone = MicrophoneState.muted;
    _track?.stop();
    _media.close();
    super.dispose();
  }
}
