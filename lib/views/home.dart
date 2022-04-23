import 'package:dieklingel_app/rtc/rtc_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  MediaRessource mediaRessource = MediaRessource();
  SignalingClient signalingClient = SignalingClient();
  RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  RtcClient? rtcClient;
  bool callIsActive = false;
  bool micIsEnabled = false;

  @override
  void initState() {
    remoteVideo.initialize();
    signalingClient.identifier = "kmayerflutter";
    rtcClient = RtcClient(signalingClient, mediaRessource, {
      "iceServers": {
        "urls": ["stun:stun1.l.google.com:19302"]
      }
    });
    rtcClient?.addEventListener(RtcClient.media_received, (stream) {
      print("track received");
      setState(() {
        remoteVideo.srcObject = stream;
      });
    });

    signalingClient.connect("ws://dieklingel.com:8889/wsrs/room?key=dev-rtc");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("dieKlingel"),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              /*child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / (16 / 9),
                child: InteractiveViewer(child: RTCVideoView(remoteVideo)),
              ),*/
              child: InteractiveViewer(child: RTCVideoView(remoteVideo)),
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
                        callIsActive
                            ? CupertinoIcons.phone_arrow_down_left
                            : CupertinoIcons.phone,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (callIsActive) {
                          rtcClient?.hangup();
                          setState(() {
                            callIsActive = false;
                            micIsEnabled = false;
                          });
                          return;
                        }
                        await mediaRessource.open(true, false);
                        await rtcClient?.invite(
                          "main",
                          options: {
                            'mandatory': {
                              'OfferToReceiveVideo': true
                            } // https://github.com/flutter-webrtc/flutter-webrtc/blob/master/example/lib/src/data_channel_sample.dart
                          },
                        );
                        setState(() {
                          callIsActive = true;
                          mediaRessource.stream?.getAudioTracks()[0].enabled =
                              micIsEnabled = false;
                        });
                      },
                    ),
                    CupertinoButton(
                      child: Icon(
                        micIsEnabled
                            ? CupertinoIcons.mic
                            : CupertinoIcons.mic_slash,
                        size: 40,
                      ),
                      onPressed: callIsActive
                          ? () {
                              mediaRessource.stream
                                  ?.getAudioTracks()[0]
                                  .enabled = !micIsEnabled;
                              setState(() {
                                micIsEnabled = !micIsEnabled;
                              });
                            }
                          : null,
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
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    remoteVideo.dispose();
    super.dispose();
  }
}
