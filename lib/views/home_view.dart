import 'dart:convert';
import 'dart:math';
import 'package:dieklingel_app/components/connection_configuration.dart';
import 'package:dieklingel_app/components/simple_alert_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../views/settings/connections_view.dart';
import '../messaging/messaging_client.dart';
import './settings/connections_view.dart';

import '../globals.dart' as app;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeView createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  final MediaRessource _mediaRessource = MediaRessource();
  final RTCVideoRenderer _remoteVideo = RTCVideoRenderer();

  SignalingClient? _signalingClient;
  MessagingClient? _messagingClient;
  RtcClient? _rtcClient;

  //String uid = "main-door:9873";
  bool callIsActive = false;
  bool micIsEnabled = false;
  bool _mqttIsConnected = false;

  @override
  void initState() {
    _remoteVideo.initialize();
    init();
    super.initState();
  }

  void init() async {
    closeCurrentConnections();
    await openConnectionsTo(app.defaultConnectionConfiguration);
    if (kIsWeb) {
      // TODO: implement push notifications for web
    } else {
      registerFcmPushNotifications();
    }
  }

  final Map<String, dynamic> _ice = {
    "iceServers": [
      {"url": "stun:stun1.l.google.com:19302"},
      {
        'url': 'turn:dieklingel.com:3478',
        'credential': '12345',
        'username': 'guest'
      },
    ]
  };

  void closeCurrentConnections() {
    _messagingClient?.disconnect();
    _messagingClient = null;
    _signalingClient = null;
    _rtcClient = null;
    setState(() {
      _mqttIsConnected = false;
    });
  }

  Future<void> openConnectionsTo(ConnectionConfiguration configuration) async {
    if (null == configuration.uri) {
      /*await displaySimpleAlertDialog(
        context,
        const Text("Error"),
        const Text("Please set an uri in configuration"),
      );*/
      return;
    }
    String scheme = configuration.uri!.scheme == "mqtt"
        ? ""
        : configuration.uri!.scheme + "://";
    _messagingClient = MessagingClient(
      "$scheme${configuration.uri!.host}",
      configuration.uri!.port,
    );
    try {
      await _messagingClient?.connect();
    } catch (exception) {
      await displaySimpleAlertDialog(
        context,
        const Text("Oh, man!"),
        Text("Could not Connect: $exception"),
        ok: "wait a sec, i'll fix it",
      );
      closeCurrentConnections();
      return;
    }
    // --
    String channelPrefix = configuration.channelPrefix ?? "";
    _signalingClient = SignalingClient.fromMessagingClient(
      _messagingClient!,
      "${channelPrefix}rtc/signaling",
      randomId(10),
    );
    // --
    _rtcClient = RtcClient(
      _signalingClient!,
      _mediaRessource,
      _ice,
    );
    _rtcClient?.addEventListener("mediatrack-received", (track) {
      print((track as MediaStream).getVideoTracks());
      setState(() {
        _remoteVideo.srcObject = track;
      });
    });
    setState(() {
      _mqttIsConnected = true;
    });
    String? token = app.preferences.getString("token");
    if (null == token) return;
    Map<String, dynamic> message = {
      "hash": "#default",
      "token": token,
    };
    _messagingClient?.send(
      "${configuration.channelPrefix}firebase/notification/token/add",
      jsonEncode(message),
    );
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
    if (null == token) return;
    app.preferences.setString("token", token);
    print("Token: $token");
  }

  Future<void> _goToConnectionsView() async {
    closeCurrentConnections();
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => const ConnectionsView(),
      ),
    );
    openConnectionsTo(app.defaultConnectionConfiguration);
  }

  void _callButtonPressed() async {
    if (callIsActive) {
      _rtcClient?.hangup();
      setState(() {
        callIsActive = false;
        micIsEnabled = false;
      });
      return;
    }
    await _mediaRessource.open(true, false);

    String? name = app.defaultConnectionConfiguration.channelPrefix;
    if (null == name) {
      await displaySimpleAlertDialog(
        context,
        const Text("here we go again"),
        Text(
          """please add a channel prefix to the configuration: ${app.defaultConnectionConfiguration.description}""",
        ),
      );
      return;
    }

    await _rtcClient?.invite(
      //"main-door:9873",
      name,
      options: {
        'offerToReceiveVideo': 1, // this works on web
        // https://webrtc.github.io/samples/src/content/peerconnection/create-offer/
        // https://github.com/webrtc/samples/blob/gh-pages/src/content/peerconnection/create-offer/js/main.js
        'mandatory': {
          'OfferToReceiveVideo': true, // this wors on mobile
        } // https://github.com/flutter-webrtc/flutter-webrtc/blob/master/example/lib/src/data_channel_sample.dart
      },
    );
    setState(() {
      callIsActive = true;
      _mediaRessource.stream?.getAudioTracks()[0].enabled =
          micIsEnabled = false;
    });
  }

  void _micButtonPressed() {
    _mediaRessource.stream?.getAudioTracks()[0].enabled = !micIsEnabled;
    setState(() {
      micIsEnabled = !micIsEnabled;
    });
  }

  String randomId(int length) {
    const String chars =
        "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (index) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.text_badge_plus,
          ),
          onPressed: callIsActive ? null : _goToConnectionsView,
        ),
      ),
      child: SafeArea(
        child: Stack(
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
                        callIsActive
                            ? CupertinoIcons.phone_arrow_down_left
                            : CupertinoIcons.phone,
                        size: 40,
                      ),
                      onPressed: _mqttIsConnected ? _callButtonPressed : null,
                    ),
                    CupertinoButton(
                      child: Icon(
                        micIsEnabled
                            ? CupertinoIcons.mic
                            : CupertinoIcons.mic_slash,
                        size: 40,
                      ),
                      onPressed: callIsActive ? _micButtonPressed : null,
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
            ),
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
