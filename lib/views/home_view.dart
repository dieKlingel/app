import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/event/system_event.dart';
import 'package:dieklingel_app/extensions/if_add_list.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/views/components/pull_down_menu_item_empty.dart';
import 'package:dieklingel_app/view_models/home_view_model.dart';
import 'package:dieklingel_app/views/home_add_view.dart';
import 'package:dieklingel_app/views/preview/camera_live_view.dart';
import 'package:dieklingel_app/views/preview/system_event_list_tile.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  late final HomeViewModel _vm = HomeViewModel();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            // TODO: make clickable
            largeTitle: Text(MqttUri.boxx.values.isEmpty
                ? "empty"
                : MqttUri.boxx.values.first
                    .host), //Text(_vm.home?.name ?? "No Home"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () {},
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.settings),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SettingsView(),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class User extends HiveObject {
  String name;

  String lastname;

  User(this.name, this.lastname);

  @override
  String toString() => "$name $lastname "; // Just for print()
}

/* class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 0;

  @override
  User read(BinaryReader reader) {
    print(reader.read());
    return User(reader.read(), "a");
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.name, writeTypeId: true);
  }
}*/
