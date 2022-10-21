import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/components/home.dart';
import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/event/system_event.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/views/preview/camera_live_view.dart';
import 'package:dieklingel_app/views/preview/message_bar.dart';
import 'package:dieklingel_app/views/preview/system_event_list_tile.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';
import '../extensions/get_mclient.dart';
import '../messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../media/media_ressource.dart';
import '../messaging/mclient.dart';
import '../rtc/mqtt_rtc_client.dart';
import '../rtc/mqtt_rtc_description.dart';
import '../rtc/rtc_client.dart';
import '../touch_scroll_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

typedef JSON = Map<dynamic, dynamic>;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final TextEditingController _bodyController = TextEditingController();
  final Queue<SystemEventListTile> _events = Queue<SystemEventListTile>();
  String? callUuid;
  bool _sendButtonIsEnabled = false;
  bool _callIsRequested = false;

  final ScrollController _controller = ScrollController();

  /*ConnectionConfiguration getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.firstWhere(
          (element) => element.isDefault,
          orElse: () =>
              context.read<AppSettings>().connectionConfigurations.first,
        );
  }*/

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() {
      if (_sendButtonIsEnabled == _bodyController.text.isNotEmpty) return;
      setState(() {
        _sendButtonIsEnabled = _bodyController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _init());
  }

  void _init() async {
    /* TODO: Hotfix: AudioSession
    Do this, so the mic starts the first time we use navigator.mediaDevices
    caues by this issue: https://github.com/flutter-webrtc/flutter-webrtc/issues/1094
    */
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.speech());
    });

    Preferences preferences = context.read<Preferences>();
    MClient mclient = context.read<MClient>();
    CallHandler handler = CallHandler.getInstance();

    mclient.subscribe("system/event", (message) {
      SystemEvent event = SystemEvent.fromJson(jsonDecode(message.message));
      SystemEventListTile tile = SystemEventListTile(
        key: Key(event.timestamp.toIso8601String()),
        event: event,
      );
      setState(() {
        _events.addFirst(tile);
      });
    });

    _reconnect();
    preferences.addListener(_reconnect);

    _takeoverActiveCall();
    handler.addListener(_takeoverActiveCall);
  }

  void _takeoverActiveCall() {
    CallHandler handler = CallHandler.getInstance();
    if (callUuid != null) return;
    if (handler.calls.isEmpty) return;
    setState(() {
      callUuid = handler.calls.keys.first;
    });
  }

  void _reconnect() async {
    MClient mclient = context.read<MClient>();
    Preferences preferences = context.read<Preferences>();
    String? id = preferences.getString("default_home_id");
    if (null == id) return;
    ObjectDB database = await ObjectDBFactory.named("homes");

    try {
      Map<dynamic, dynamic> result = (await database.first({"_id": id}));
      Home home = Home.fromJson(result.cast<String, dynamic>());
      if (home.description == mclient.mqttRtcDescription) return;
      mclient.disconnect();
      mclient.mqttRtcDescription = home.description;
      await mclient.connect(
        username: home.username,
        password: home.password,
      );
    } on SocketException catch (exception) {
      mclient.disconnect();
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Connection Error"),
          content: Text(exception.osError?.message ?? exception.message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              isDefaultAction: true,
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }
    database.close();
  }

  Future<void> _onRefresh() async {
    MClient mclient = context.read<MClient>();
    if (mclient.isNotConnected()) return;
    String? response = await mclient.get("request/events/", "events");

    if (null == response) return;

    Iterable iterable = jsonDecode(response);
    List<SystemEventListTile> events = List<SystemEventListTile>.from(
      iterable.map(
        (e) {
          SystemEvent event = SystemEvent.fromJson(e);
          SystemEventListTile tile = SystemEventListTile(
            key: Key(event.timestamp.toIso8601String()),
            event: event,
          );
          return tile;
        },
      ),
    );
    events.sort(((a, b) => b.event.timestamp.compareTo(a.event.timestamp)));
    setState(() {
      _events.clear();
      _events.addAll(events);
    });
  }

  void _onUserNotificationSendPressed() {
    context.read<MClient>().publish(
          MClientTopicMessage(
            topic: "io/user/notification",
            message: _bodyController.text,
          ),
        );
    _bodyController.clear();
  }

  void _onCallButtonPressed() async {
    MClient mclient = context.read<MClient>();
    CallHandler handler = CallHandler.getInstance();
    String? uuid = callUuid;
    MqttRtcDescription? des = mclient.mqttRtcDescription;

    if (null == uuid) {
      setState(() {
        _callIsRequested = true;
      });
      uuid = const Uuid().v4();
      MqttRtcDescription description = MqttRtcDescription(
        host: "wss://server.dieklingel.com",
        port: 9002,
        channel: "com.dieklingel/mayer/kai/rtc/$uuid/",
      );
      MqttRtcDescription descriptionc = MqttRtcDescription(
        host: "server.dieklingel.com",
        port: 1883,
        channel: "com.dieklingel/mayer/kai/rtc/$uuid/",
      );

      String? result = await mclient.get(
        "request/rtc/test/",
        description.toString(),
      );
      if (null == result) {
        return;
      }

      if (des == null) return;

      MqttRtcClient mqttRtcClient = MqttRtcClient.invite(
        descriptionc,
        MediaRessource(),
      );

      await mqttRtcClient.mediaRessource.open(true, false);

      await mqttRtcClient.init(iceServers: {
        "iceServers": [
          {"url": "stun:stun1.l.google.com:19302"},
          {
            "urls": "turn:dieklingel.com:3478",
            "username": "guest",
            "credential": "12345"
          },
          {"urls": "stun:openrelay.metered.ca:80"},
          {
            "urls": "turn:openrelay.metered.ca:80",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          },
          {
            "urls": "turn:openrelay.metered.ca:443",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          },
          {
            "urls": "turn:openrelay.metered.ca:443?transport=tcp",
            "username": "openrelayproject",
            "credential": "openrelayproject"
          }
        ],
        "sdpSemantics": "unified-plan" // important to work
      }, transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.RecvOnly,
        ),
      ]);
      await mqttRtcClient.open();

      handler.callkeep.startCall(
        uuid,
        "dieKlingel",
        "dieKlingel",
        handleType: "generic",
        hasVideo: false,
      );
      handler.calls[uuid] = mqttRtcClient;
      setState(() {
        callUuid = uuid;
        _callIsRequested = false;
      });
    } else {
      if (handler.calls.containsKey(uuid)) {
        await handler.calls[uuid]?.close();
        handler.calls.remove(uuid);
        handler.callkeep.endCall(uuid);
        setState(() {
          callUuid = null;
        });
        _takeoverActiveCall();
      }
    }
  }

  Widget _refreshIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "swipe down to refresh",
            style: TextStyle(color: Colors.grey),
          ),
          Icon(
            CupertinoIcons.down_arrow,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _scrollView(BuildContext context) {
    bool listIsVisible = _events.isNotEmpty;
    CallHandler handler = CallHandler.getInstance();
    MqttRtcClient? client = handler.calls[callUuid];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: CupertinoScrollbar(
        controller: _controller,
        child: CustomScrollView(
          scrollBehavior: TouchScrollBehavior(),
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          clipBehavior: Clip.none,
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: _onRefresh,
            ),
            SliverToBoxAdapter(
              child: client != null
                  ? CameraLiveView(
                      mediaRessource: client.mediaRessource,
                      rtcVideoRenderer: client.rtcVideoRenderer,
                    )
                  : _callIsRequested
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CupertinoActivityIndicator(
                            radius: 14,
                          ),
                        )
                      : Container(),
            ),
            SliverList(
              delegate: listIsVisible
                  ? SliverChildListDelegate(_events.toList())
                  : SliverChildListDelegate(
                      [
                        _refreshIndicator(context),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MClient mclient = context.watch<MClient>();
    print(mclient.connectionState);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: mclient.connectionState == MqttConnectionState.connecting
            ? const CupertinoActivityIndicator()
            : const SizedBox(width: 0),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _scrollView(context),
            ),
            MessageBar(
              controller: _bodyController,
              onCallPressed:
                  mclient.isConnected() ? _onCallButtonPressed : null,
              onSendPressed: mclient.isConnected() && _sendButtonIsEnabled
                  ? _onUserNotificationSendPressed
                  : null,
              isInCall: callUuid != null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    Preferences preferences = context.read<Preferences>();
    CallHandler handler = CallHandler.getInstance();

    preferences.removeListener(_reconnect);
    handler.removeListener(_takeoverActiveCall);

    super.deactivate();
  }
}
