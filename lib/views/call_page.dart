import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter_voip_kit/call.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter/cupertino.dart';

class CallPage extends StatefulWidget {
  final MediaRessource mediaRessource;
  final RTCVideoRenderer rtcVideoRenderer;
  final String uuid;
  final Key heroKey;

  const CallPage({
    super.key,
    required this.mediaRessource,
    required this.rtcVideoRenderer,
    required this.heroKey,
    required this.uuid,
  });

  @override
  State<CallPage> createState() => _CallPage();
}

class _CallPage extends State<CallPage> {
  void _onMicButtonPressed() {
    Call? call = getCurrentCall();
    if (null == call) return;
    setState(() {
      call.mute(muted: !call.muted);
    });
  }

  Call? getCurrentCall() {
    CallHandler handler = CallHandler.getInstance();
    if (handler.calls.any((element) => element.uuid == widget.uuid)) {
      Call call = handler.calls.firstWhere((call) => call.uuid == widget.uuid);
      return call;
    }
    return null;
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
                            getCurrentCall() == null || getCurrentCall()!.muted
                                ? CupertinoIcons.mic_off
                                : CupertinoIcons.mic,
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
