import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import 'call_active_view_model.dart';
import 'widgets/microphone_button.dart';
import 'widgets/speaker_button.dart';

class CallActiveView extends StatelessWidget {
  const CallActiveView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CallActiveViewModel>().onHangup().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    });

    final renderer = context.select(
      (CallActiveViewModel vm) => vm.renderer,
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
                const MicrophoneButton(),
                const SpeakerButton(),
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
