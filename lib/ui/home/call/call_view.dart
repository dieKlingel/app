import 'package:dieklingel_app/ui/home/call/call_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import 'widgets/microphone_button.dart';
import 'widgets/speaker_button.dart';

class CallView extends StatelessWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    final renderer = context.select((CallViewModel vm) => vm.renderer);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Live"),
      ),
      child: Stack(
        children: [
          InteractiveViewer(
            child: Hero(
              tag: "RTC_VIDEO_STREAM",
              child: RTCVideoView(renderer),
            ),
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
                  /*CupertinoButton(
                    color: Colors.amber,
                    onPressed: null,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(999),
                    child: const Icon(CupertinoIcons.lock_fill),
                  ),*/
                  CupertinoButton(
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(999),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark),
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
