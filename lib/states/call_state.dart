import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallState {}

class CallErrorState extends CallState {
  final String errorMessage;

  CallErrorState({required this.errorMessage});
}

class CallInitatedState extends CallState {}

class CallActiveState extends CallState {
  final MicrophoneState microphoneState;
  final SpeakerState speakerState;
  final RTCVideoRenderer renderer;

  CallActiveState({
    required this.microphoneState,
    required this.speakerState,
    required this.renderer,
  });
}

class CallEndedState extends CallState {}

abstract class CallEvent {}

class CallStart extends CallEvent {}

class CallHangup extends CallEvent {}

class CallToogleMicrophone extends CallEvent {}

class CallToogleSpeaker extends CallEvent {}
