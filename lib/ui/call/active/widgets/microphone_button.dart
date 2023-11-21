import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../models/audio/microphone_state.dart';
import '../call_active_view_model.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    final microphone = context.select(
      (CallActiveViewModel vm) => vm.microphone,
    );

    return PullDownButton(
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.microphone = MicrophoneState.muted;
            },
            title: "Muted",
            icon: CupertinoIcons.mic_slash_fill,
            selected: microphone == MicrophoneState.muted,
          ),
          PullDownMenuItem.selectable(
            // TODO: enable microhone
            enabled: false,
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.microphone = MicrophoneState.unmuted;
            },
            title: "Unmuted",
            icon: CupertinoIcons.mic_fill,
            selected: microphone == MicrophoneState.unmuted,
          ),
        ];
      },
      buttonBuilder: (context, showMenu) {
        return CupertinoButton(
          onPressed: showMenu,
          child: Icon(
            (() {
              switch (microphone) {
                case MicrophoneState.muted:
                  return CupertinoIcons.mic_slash_fill;
                case MicrophoneState.unmuted:
                  return CupertinoIcons.mic_fill;
              }
            })(),
          ),
        );
      },
    );
  }
}
