import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import 'call_active_view_model.dart';
import 'widgets/microphone_button.dart';
import 'widgets/speaker_button.dart';

class CallActiveView extends StatefulWidget {
  const CallActiveView({super.key});

  @override
  State<CallActiveView> createState() => _CallActiveViewState();
}

class _CallActiveViewState extends State<CallActiveView> {
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
      (CallActiveViewModel vm) => vm.renderer,
    );

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          InteractiveViewer(
            child: RTCVideoView(renderer),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const MicrophoneButton(),
                  const SpeakerButton(),
                  CupertinoButton(
                    color: Colors.amber,
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(999),
                    child: const Icon(CupertinoIcons.lock_fill),
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
            ),
          )
        ],
      ),
    );
  }
}
