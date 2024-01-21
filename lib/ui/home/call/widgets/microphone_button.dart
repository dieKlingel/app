import 'package:dieklingel_app/ui/home/call/call_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../models/audio/microphone_state.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({super.key});

  @override
  Widget build(BuildContext context) {
    final microphone = context.select((CallViewModel vm) => vm.microphone);

    return PullDownButton(
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallViewModel>();
              vm.microphone = MicrophoneState.muted;
            },
            title: "Muted",
            icon: CupertinoIcons.mic_slash_fill,
            selected: microphone == MicrophoneState.muted,
          ),
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallViewModel>();
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
          color: Colors.lightBlue,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(999),
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
