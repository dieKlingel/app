enum SpeakerState {
  muted,
  headphone,
  speaker;

  const SpeakerState();

  SpeakerState next({List<SpeakerState> skip = const []}) {
    int next = (index + 1) % SpeakerState.values.length;
    SpeakerState state = SpeakerState.values[next];

    while (state != this && skip.contains(state)) {
      state = state.next();
    }

    return state;
  }
}
