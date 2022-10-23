import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter/cupertino.dart';

class CallPage extends StatefulWidget {
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer;
  final Key heroKey;

  const CallPage({
    super.key,
    required this.mediaRessource,
    required this.rtcVideoRenderer,
    required this.heroKey,
  });

  @override
  State<CallPage> createState() => _CallPage();
}

class _CallPage extends State<CallPage> {
  void _onMicButtonPressed() {
    MediaStreamTrack? audioTrack =
        widget.mediaRessource.stream?.getAudioTracks().first;
    if (null == audioTrack) return;
    setState(() {
      audioTrack.enabled = !audioTrack.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: InteractiveViewer(
                child: Hero(
                  tag: widget.heroKey,
                  child: RTCVideoView(
                    widget.rtcVideoRenderer,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                          onPressed: _onMicButtonPressed,
                          child: Icon(
                            widget.mediaRessource.stream
                                        ?.getAudioTracks()
                                        .first
                                        .enabled ??
                                    false
                                ? CupertinoIcons.mic
                                : CupertinoIcons.mic_off,
                            size: 40,
                          )),
                      const CupertinoButton(
                        onPressed: null,
                        child: Icon(
                          CupertinoIcons.speaker_2,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
