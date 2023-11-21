import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../models/audio/speaker_state.dart';
import '../call_active_view_model.dart';

class SpeakerButton extends StatelessWidget {
  const SpeakerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final speaker = context.select(
      (CallActiveViewModel vm) => vm.speaker,
    );

    return PullDownButton(
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.speaker = SpeakerState.muted;
            },
            title: "Muted",
            icon: CupertinoIcons.speaker_slash_fill,
            selected: speaker == SpeakerState.muted,
          ),
          if (!kIsWeb)
            PullDownMenuItem.selectable(
              onTap: () {
                final vm = context.read<CallActiveViewModel>();
                vm.speaker = SpeakerState.earphone;
              },
              title: "Earphone",
              icon: CupertinoIcons.ear,
              selected: speaker == SpeakerState.earphone,
            ),
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.speaker = SpeakerState.speaker;
            },
            title: "Speaker",
            icon: CupertinoIcons.speaker_2_fill,
            selected: speaker == SpeakerState.speaker,
          ),
        ];
      },
      buttonBuilder: (context, showMenu) {
        return CupertinoButton(
          onPressed: showMenu,
          child: Icon(
            (() {
              switch (speaker) {
                case SpeakerState.muted:
                  return CupertinoIcons.speaker_slash_fill;
                case SpeakerState.earphone:
                  return CupertinoIcons.ear;
                case SpeakerState.speaker:
                  return CupertinoIcons.speaker_2_fill;
              }
            })(),
          ),
        );
      },
    );
  }
}
