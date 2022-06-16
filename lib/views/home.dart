import 'dart:convert';

import 'package:dieklingel_app/messaging/messaging_client.dart';
import 'package:dieklingel_app/signaling/signaling_message.dart';
import 'package:dieklingel_app/signaling/signaling_message_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  late final MessagingClient _messagingClient;
  late final RtcClient _rtcClient;
  late final SignalingClient _signalingClient;
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _remoteVideo = RTCVideoRenderer();
  String uid = "main-door:9873";
  bool callIsActive = false;
  bool micIsEnabled = false;

  @override
  void initState() {
    _remoteVideo.initialize();
    init();
    super.initState();
  }

  void init() async {
    // init messaging client
    _messagingClient = MessagingClient("dieklingel.com", 1883);
    await _messagingClient.connect();
    // init signaling client
    String uid = "main-door:9873";
    _signalingClient = SignalingClient.fromMessagingClient(
      _messagingClient,
      "com.dieklingel/$uid/rtc/signaling",
      "app",
    );
    // init rtc client
    var ice = <String, dynamic>{
      "iceServers": [
        {"url": "stun:stun1.l.google.com:19302"},
        {
          'url': 'turn:dieklingel.com:3478',
          'credential': '12345',
          'username': 'guest'
        },
      ]
    };
    _rtcClient = RtcClient(
      _signalingClient,
      _mediaRessource,
      ice,
    );
    _rtcClient.addEventListener("mediatrack-received", (track) {
      _remoteVideo.srcObject = track;
    });
    // init firebase
    registerFcmPushNotifications();
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
      Map<String, dynamic> message = {
        "hash": "app",
        "token": token,
      };
      String raw = jsonEncode(message);
      _messagingClient.send(
        "com.dieklingel/$uid/firebase/notification/token/add",
        raw,
      );
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
              child: InteractiveViewer(child: RTCVideoView(_remoteVideo)),
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
                          _rtcClient.hangup();
                          setState(() {
                            callIsActive = false;
                            micIsEnabled = false;
                          });
                          return;
                        }
                        await _mediaRessource.open(true, true);
                        await _rtcClient.invite(
                          "main-door:9873",
                          options: {
                            'mandatory': {
                              'OfferToReceiveVideo': true
                            } // https://github.com/flutter-webrtc/flutter-webrtc/blob/master/example/lib/src/data_channel_sample.dart
                          },
                        );
                        setState(() {
                          callIsActive = true;
                          _mediaRessource.stream?.getAudioTracks()[0].enabled =
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
                              _mediaRessource.stream
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
                    const CupertinoButton(
                      child: Icon(
                        CupertinoIcons.lock,
                        size: 40,
                      ),
                      onPressed: null,
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
    _remoteVideo.dispose();
    super.dispose();
  }
}
