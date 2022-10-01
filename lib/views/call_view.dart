import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../media/media_ressource.dart';

class CallView extends StatefulWidget {
  const CallView({Key? key}) : super(key: key);

  @override
  State<CallView> createState() => _CallView();
}

class _CallView extends State<CallView> {
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _remoteVideo = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _remoteVideo.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: InteractiveViewer(
            child: RTCVideoView(_remoteVideo),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  child: Icon(
                    CupertinoIcons.phone_arrow_down_left,
                    size: 40,
                  ),
                  onPressed: null,
                ),
                CupertinoButton(
                  child: Icon(
                    CupertinoIcons.mic_slash,
                    size: 40,
                  ),
                  onPressed: null,
                ),
                const CupertinoButton(
                  child: Icon(
                    CupertinoIcons.speaker_1,
                    size: 40,
                  ),
                  onPressed: null,
                ),
                CupertinoButton(
                  child: const Icon(
                    CupertinoIcons.lock,
                    size: 40,
                  ),
                  onPressed: null,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _remoteVideo.dispose();
    super.dispose();
  }
}
