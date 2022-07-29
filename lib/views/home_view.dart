import 'dart:convert';
import 'dart:math';
import 'package:dieklingel_app/components/numpad.dart';
import 'package:dieklingel_app/components/passcode_dots.dart';
import 'package:dieklingel_app/crypto/sha2562.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtc/rtc_client.dart';
import '../signaling/signaling_client.dart';
import '../media/media_ressource.dart';
import '../messaging/messaging_client.dart';
import '../components/connection_configuration.dart';
import '../components/simple_alert_dialog.dart';
import 'settings/settings_view_page.dart';
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
    if (null == configuration.uri) return;
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
    List<Map<String, dynamic>> iceServers = List.empty(growable: true);
    app.iceConfigurations.forEach(((element) {
      Map<String, dynamic> b = element.toJson();
      b.remove("_key");
      if (b["username"] != null && b["username"]!.isEmpty) {
        b.remove("username");
      }
      if (b["credential"] != null && b["credential"]!.isEmpty) {
        b.remove("credential");
      }
      iceServers.add(b);
    }));
    Map<String, dynamic> ice = {
      "iceServers": iceServers,
      "sdpSemantics": "unified-plan" // important to work
    };
    // --
    _rtcClient = RtcClient(
      _signalingClient!,
      _mediaRessource,
      ice,
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
        builder: (BuildContext context) => const SettingsViewPage(),
        //builder: (BuildContext context) => const ConnectionsView(),
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
        _remoteVideo.srcObject = null;
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

    await _rtcClient?.invite(name, transceivers: [
      RtcTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        direction: TransceiverDirection.SendRecv,
      ),
      RtcTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        direction: TransceiverDirection.RecvOnly,
      ),
    ]);
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

  void _unlock(String passcode) {
    ConnectionConfiguration configuration = app.defaultConnectionConfiguration;
    String channelPrefix = configuration.channelPrefix ?? "";
    String hash = sha2562.convert(utf8.encode(passcode)).toString();
    _messagingClient?.send("${channelPrefix}io/action/unlock/passcode", hash);
  }

  void _showPasscodeDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        String passcode = "";
        int passcodeLength = 6;
        return StatefulBuilder(builder: (context, setState) {
          return CupertinoAlertDialog(
            title: const Text("Passcode ?"),
            content: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: PasscodeDots(
                    amount: passcodeLength,
                    count: passcode.length,
                  ),
                ),
                Numpad(
                  onInput: (input) {
                    setState(() {
                      passcode += input;
                    });
                    if (passcode.length == passcodeLength) {
                      _unlock(passcode);
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: (() {
                  Navigator.of(context).pop();
                }),
              ),
            ],
          );
        });
      },
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
                    CupertinoButton(
                      child: const Icon(
                        CupertinoIcons.lock,
                        size: 40,
                      ),
                      onPressed: _mqttIsConnected
                          ? () => _showPasscodeDialog(context)
                          : null,
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
