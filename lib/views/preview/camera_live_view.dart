import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../call_view_page.dart';

class CameraLiveView extends StatelessWidget {
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer;

  const CameraLiveView({
    super.key,
    required this.mediaRessource,
    required this.rtcVideoRenderer,
  });

  Widget _livedot(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = rtcVideoRenderer.videoWidth.toDouble() /
        rtcVideoRenderer.videoHeight.toDouble();
    if (aspectRatio <= 0.0) {
      aspectRatio = 1;
    }

    return ChangeNotifierProvider(
      create: ((context) => rtcVideoRenderer),
      child: Consumer<RTCVideoRenderer>(
        builder: (context, value, child) {
          return value.videoHeight <= 0 || value.videoWidth <= 0
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Hero(
                    tag: const Key("call_view_page"),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GestureDetector(
                          onTap: () async {
                            context.pushTransparentRoute(CallViewPage(
                              mediaRessource: mediaRessource,
                              rtcVideoRenderer: rtcVideoRenderer,
                            ));
                          },
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    value.videoWidth / value.videoHeight,
                                child: RTCVideoView(
                                  rtcVideoRenderer,
                                ),
                              ),
                              _livedot(context),
                            ],
                          )),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
