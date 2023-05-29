enum MicrophoneState {
  muted,
  unmuted;

  const MicrophoneState();

  MicrophoneState next({List<MicrophoneState> skip = const []}) {
    int next = (index + 1) % MicrophoneState.values.length;
    MicrophoneState state = MicrophoneState.values[next];

    while (state != this && skip.contains(state)) {
      state = state.next();
    }

    return state;
  }
}
