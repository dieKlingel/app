import 'package:dieklingel_app/ui/call/active/call_active_view_model.dart';
import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../models/audio/speaker_state.dart';

class CallActiveView extends StatefulWidget {
  const CallActiveView({super.key});

  @override
  State<CallActiveView> createState() => _CallActiveViewState();
}

class _CallActiveViewState extends State<CallActiveView> {
  bool isEarphone = false;

  @override
  void initState() {
    super.initState();

    context.read<CallActiveViewModel>().onHangup().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final renderer = context.select(
      (CallActiveViewModel value) => value.call.renderer,
    );

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          InteractiveViewer(
            child: RTCVideoView(renderer),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MicrophoneButton(),
                _SpeakerButton(),
                const CupertinoButton(
                  onPressed: null,
                  child: Icon(CupertinoIcons.lock_fill),
                ),
                Hero(
                  tag: "call_hangup_button",
                  child: CupertinoButton(
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(999),
                    onPressed: () {
                      context.read<CallActiveViewModel>().hangup();
                    },
                    child: const Icon(CupertinoIcons.xmark),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MicrophoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final microphoneState = context.select(
      (CallActiveViewModel value) => value.call.microphone,
    );

    return PullDownButton(
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.call.microphone = MicrophoneState.muted;
            },
            title: "Muted",
            icon: CupertinoIcons.mic_slash_fill,
            selected: microphoneState == MicrophoneState.muted,
          ),
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.call.microphone = MicrophoneState.unmuted;
            },
            title: "Unmuted",
            icon: CupertinoIcons.mic_fill,
            selected: microphoneState == MicrophoneState.unmuted,
          ),
        ];
      },
      buttonBuilder: (context, showMenu) {
        return CupertinoButton(
          onPressed: showMenu,
          child: Icon(
            (() {
              switch (microphoneState) {
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

class _SpeakerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final speakerState = context.select(
      (CallActiveViewModel value) => value.call.speaker,
    );

    return PullDownButton(
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.call.speaker = SpeakerState.muted;
            },
            title: "Muted",
            icon: CupertinoIcons.speaker_slash_fill,
            selected: speakerState == SpeakerState.muted,
          ),
          if (!kIsWeb)
            PullDownMenuItem.selectable(
              onTap: () {
                final vm = context.read<CallActiveViewModel>();
                vm.call.speaker = SpeakerState.earphone;
              },
              title: "Earphone",
              icon: CupertinoIcons.ear,
              selected: speakerState == SpeakerState.earphone,
            ),
          PullDownMenuItem.selectable(
            onTap: () {
              final vm = context.read<CallActiveViewModel>();
              vm.call.speaker = SpeakerState.speaker;
            },
            title: "Speaker",
            icon: CupertinoIcons.speaker_2_fill,
            selected: speakerState == SpeakerState.speaker,
          ),
        ];
      },
      buttonBuilder: (context, showMenu) {
        return CupertinoButton(
          onPressed: showMenu,
          child: Icon(
            (() {
              switch (speakerState) {
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
