import 'package:dieklingel_app/signaling/signaling_message.dart';
import 'package:dieklingel_app/signaling/signaling_message_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtc/rtc_client.dart';
import '../signaling/signaling_client_mqtt.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  MediaRessource mediaRessource = MediaRessource();
  SignalingClient signalingClient = SignalingClientMqtt();
  //SignalingClientWs();
  RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  RtcClient? rtcClient;
  bool callIsActive = false;
  bool micIsEnabled = false;

  @override
  void initState() {
    registerFcmPushNotifications();
    remoteVideo.initialize();
    signalingClient.identifier = "flutterapp";
    signalingClient.addEventListener(
        "broadcast", (data) => {print("listen object")});

    // TODO: platform specific implementation
    /*var ice = {
      "urls": ["stun:stun1.l.google.com:19302"]
    };*/
    var ice = <String, dynamic>{
      "iceServers": [
        {"url": "stun:stun1.l.google.com:19302"},
        {
          'url': 'turn:192.158.29.39:3478?transport=tcp',
          'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
          'username': '28224511:1379330808'
        },
      ]
    };
    /*var ice = {
      "iceServers": {
        "urls": ["stun:stun1.l.google.com:19302"]
      }
    }*/

    rtcClient = RtcClient(signalingClient, mediaRessource, ice);
    rtcClient?.addEventListener(RtcClient.mediaReceived, (stream) {
      print("track received");
      setState(() {
        remoteVideo.srcObject = stream;
      });
    });

    signalingClient.connect("dieklingel.com");
    //signalingClient.connect("ws://dieklingel.com:8889/wsrs/room?key=dev-rtc");
    super.initState();
  }

  void registerFcmPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await FirebaseMessaging.instance.getToken();
    if (null != token) {
      print("Token: $token");
    }
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
                          "flutterbase",
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
                      onPressed: () {
                        SignalingMessage message = SignalingMessage();
                        message.type = SignalingMessageType.leave;
                        message.from = "Debugger";
                        message.to = "noreply";
                        message.data = {};
                        print("Hallo");
                        signalingClient.send(message);
                      },
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
