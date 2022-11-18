import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/components/home.dart';
import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/event/system_event.dart';
import 'package:dieklingel_app/extensions/if_add_list.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/views/components/pull_down_menu_item_empty.dart';
import 'package:dieklingel_app/views/home_view_model.dart';
import 'package:dieklingel_app/views/sheets/home_config_sheet.dart';
import 'package:dieklingel_app/views/preview/camera_live_view.dart';
import 'package:dieklingel_app/views/preview/system_event_list_tile.dart';
import 'package:dieklingel_app/views/settings_page.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:objectdb/objectdb.dart';
import 'package:pull_down_button/pull_down_button.dart';
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

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomePage();
}

class _HomePage extends State<HomeView> {
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
      Home home = Home.fromMap(result.cast<String, dynamic>());
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

  Widget _navigationBarTrailing(BuildContext context) {
    HomeViewModel vm = context.watch<HomeViewModel>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () async {
              Home? home = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const HomeConfigSheet(),
                ),
              );
              if (home == null) return;
              vm.insert(home);
              vm.home = home;
            }),
        PullDownButton(
          itemBuilder: (context) => <PullDownMenuEntry>[]
              .ifAdd(
                PullDownMenuItem(
                  title: "Settings",
                  icon: CupertinoIcons.settings,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              )
              .ifAdd(
                  condition: vm.homes.isNotEmpty,
                  const PullDownMenuDivider.large())
              .forAdd(
                vm.homes
                    .map(
                      (e) => SelectablePullDownMenuItem(
                        title: e.name,
                        selected: vm.home == e,
                        onTap: () {
                          vm.home = e;
                        },
                      ),
                    )
                    .toList(),
              )
              .ifNotNull(
                vm.home,
                const PullDownMenuDivider.large(),
              )
              .ifNotNull(
                vm.home,
                PullDownMenuItem(
                  title: "Edit",
                  icon: CupertinoIcons.pencil,
                  onTap: () async {
                    Home? home = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => HomeConfigSheet(
                          home: vm.home,
                        ),
                      ),
                    );
                    if (home == null) return;
                    vm.insert(home);
                  },
                ),
              )
              .ifNotNull(
                vm.home,
                PullDownMenuItem(
                  title: "Delete",
                  icon: CupertinoIcons.delete,
                  onTap: () {
                    if (vm.home == null) return;
                    vm.delete(vm.home!);
                    vm.home = vm.homes.isEmpty ? null : vm.homes.first;
                  },
                  textStyle: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(color: Colors.red),
                ),
              ),
          buttonBuilder: (context, showMenu) => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: showMenu,
            child: const Icon(CupertinoIcons.ellipsis_circle),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    HomeViewModel vm = context.watch<HomeViewModel>();
    MClient mclient = context.watch<MClient>();
    CallHandler handler = context.watch<CallHandler>();

    return CupertinoPageScaffold(
      //navigationBar: _navigationBar(context),
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(vm.home?.name ?? "Home"),
            trailing: _navigationBarTrailing(context),
          )
        ],
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
