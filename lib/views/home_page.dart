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
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';
import '../extensions/get_mclient.dart';
import '../messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';

import '../messaging/mclient.dart';
import '../rtc/mqtt_rtc_client.dart';
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
  bool _sendButtonIsEnabled = false;

  final ScrollController _controller = ScrollController();

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
    CallHandler handler = context.read<CallHandler>();

    mclient.subscribe("system/event/", (message) {
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
    CallHandler handler = context.read<CallHandler>();
    String? uuid = handler.active?.uuid; //callUuid;

    if (null == uuid) {
      uuid = const Uuid().v4().toUpperCase();
      handler.prepare(uuid, mclient);
      FlutterVoipKit.startCall("01234567890", uuid: uuid);
    } else if (handler.calls.any((element) => element.uuid == uuid)) {
      await FlutterVoipKit.endCall(uuid);
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
    CallHandler handler = context.watch<CallHandler>();

    List<MapEntry<String, MqttRtcClient>> clients =
        handler.clients.entries.toList();

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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    clients.length,
                    (index) {
                      String uuid = clients[index].key;
                      MqttRtcClient client = clients[index].value;

                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CameraLiveView(
                          key: Key(uuid),
                          mediaRessource: client.mediaRessource,
                          rtcVideoRenderer: client.rtcVideoRenderer,
                          uuid: uuid,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
    CallHandler handler = context.watch<CallHandler>();
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
              isInCall: handler.active != null,
              onUnlockPressed: null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    Preferences preferences = context.read<Preferences>();

    preferences.removeListener(_reconnect);

    super.deactivate();
  }
}
