import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const VideoView(this.renderer, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: RTCVideoView(renderer),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemBackground,
                context,
              ).withOpacity(0.85),
              padding: const EdgeInsets.all(10.0),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.antenna_radiowaves_left_right),
                  SizedBox(width: 8.0),
                  Text("Videostream"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
