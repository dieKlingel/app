import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallState {}

class CallInitatedState extends CallState {}

class CallActiveState extends CallState {
  final bool isMuted;
  final bool speakerIsEarphone;
  final RTCVideoRenderer renderer;

  CallActiveState({
    required this.isMuted,
    required this.renderer,
    required this.speakerIsEarphone,
  });
}

class CallEndedState extends CallState {}

abstract class CallEvent {}

class CallStart extends CallEvent {}

class CallHangup extends CallEvent {}

class CallMute extends CallEvent {
  final bool isMuted;

  CallMute({required this.isMuted});
}

class CallSpeaker extends CallEvent {
  final bool isEarphone;

  CallSpeaker({required this.isEarphone});
}
