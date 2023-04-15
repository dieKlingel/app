import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("MicrophoneState", () {
    group(".next()", () {
      test("without skip; muted to unmuted", () {
        MicrophoneState state = MicrophoneState.muted;

        MicrophoneState actual = state.next();
        MicrophoneState expected = MicrophoneState.unmuted;

        expect(actual, equals(expected));
      });

      test("without skip; unmuted to muted", () {
        MicrophoneState state = MicrophoneState.unmuted;

        MicrophoneState actual = state.next();
        MicrophoneState expected = MicrophoneState.muted;

        expect(actual, equals(expected));
      });

      test("skip all; muted to muted", () {
        MicrophoneState state = MicrophoneState.muted;

        MicrophoneState actual = state.next(skip: MicrophoneState.values);
        MicrophoneState expected = MicrophoneState.muted;

        expect(actual, equals(expected));
      });

      test("skip unmuted; muted to muted", () {
        MicrophoneState state = MicrophoneState.muted;

        MicrophoneState actual = state.next(skip: [MicrophoneState.unmuted]);
        MicrophoneState expected = MicrophoneState.muted;

        expect(actual, equals(expected));
      });

      test("skip muted; muted to unmuted", () {
        MicrophoneState state = MicrophoneState.muted;

        MicrophoneState actual = state.next(skip: [MicrophoneState.muted]);
        MicrophoneState expected = MicrophoneState.unmuted;

        expect(actual, equals(expected));
      });
    });
  });
}
