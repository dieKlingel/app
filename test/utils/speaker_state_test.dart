import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("SpeakerState", () {
    group(".next()", () {
      test("without skip; muted to headphone", () {
        SpeakerState state = SpeakerState.muted;

        SpeakerState actual = state.next();
        SpeakerState expected = SpeakerState.headphone;

        expect(actual, equals(expected));
      });

      test("without skip; headphone to speaker", () {
        SpeakerState state = SpeakerState.headphone;

        SpeakerState actual = state.next();
        SpeakerState expected = SpeakerState.speaker;

        expect(actual, equals(expected));
      });

      test("without skip; speaker to muted", () {
        SpeakerState state = SpeakerState.speaker;

        SpeakerState actual = state.next();
        SpeakerState expected = SpeakerState.muted;

        expect(actual, equals(expected));
      });

      test("skip all; headphone to headphone", () {
        SpeakerState state = SpeakerState.headphone;

        SpeakerState actual = state.next(skip: SpeakerState.values);
        SpeakerState expected = SpeakerState.headphone;

        expect(actual, equals(expected));
      });

      test("skip headphone; muted to speaker", () {
        SpeakerState state = SpeakerState.muted;

        SpeakerState actual = state.next(skip: [SpeakerState.headphone]);
        SpeakerState expected = SpeakerState.speaker;

        expect(actual, equals(expected));
      });

      test("skip muted; speaker to headphone", () {
        SpeakerState state = SpeakerState.speaker;

        SpeakerState actual = state.next(skip: [SpeakerState.muted]);
        SpeakerState expected = SpeakerState.headphone;

        expect(actual, equals(expected));
      });
    });
  });
}
