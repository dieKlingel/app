import 'dart:convert';

import 'package:dieklingel_app/views/settings/connection_configuration_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/connection_configuration.dart';
import '../messaging/messaging_client.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../views/settings/connections.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeView createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
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
    Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? rawConfiguration = prefs.getString("configuration");
      if (null != rawConfiguration) {
        await Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ConnectionConfigurationView(
              backButtonEnabled: false,
            ),
          ),
        );
      } else {
        //ConnectionConfiguration configuration =
        //    ConnectionConfiguration.fromJson(jsonDecode(rawConfiguration));
      }
    });
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
        "hash": "#kai",
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: CupertinoButton(
            child: const Icon(
              CupertinoIcons.settings,
              size: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      ConnectionConfigurationView(),
                ),
              );
            }),
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
                        await _mediaRessource.open(true, false);
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
