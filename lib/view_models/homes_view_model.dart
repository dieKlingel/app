import 'dart:async';
import 'dart:io';

import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:injectable/injectable.dart';

import '../models/home.dart';

@injectable
class HomesViewModel extends ChangeNotifier {
  late final StreamSubscription _homeSubscription;
  final MClient client;
  MqttRtcClient? rtc;

  HomesViewModel(this.client) {
    _homeSubscription = Home.boxx.watch().listen((event) {
      if (event.value == home) {
        connect();
      }
      notifyListeners();
    });
    client.addListener(notifyListeners);
    connect();
  }

  List<Home> get homes => Home.boxx.values.toList();

  Home? get home {
    Box box = Hive.box("settings");
    dynamic key = box.get("home");
    Home? home;
    if (key != null) {
      home = Home.boxx.get(key);
    }
    if (home == null && homes.isNotEmpty) {
      home = homes.first;
    }
    return home;
  }

  set home(Home? home) {
    Box box = Hive.box("settings");
    if (home == null) {
      box.delete("home");
      notifyListeners();
      return;
    }
    if (home.key == null) {
      throw "cannot save a home as defautl, if not save into a box. Did you forgett to call home.save() ?";
    }
    box.put("home", home.key);
    connect();
    notifyListeners();
  }

  Future<void> connect() async {
    if (home == null) {
      return;
    }
    MqttUri? uri = home?.uri;
    if (uri == null) {
      return;
    }
    await disconnect();
    try {
      await client.connect(
        uri,
        username: home?.username,
        password: home?.password,
      );
    } on SocketException catch (e) {
      // TODO: inform the user
      print(e.message);
    }
  }

  Future<void> disconnect() async {
    await client.disconnect();
  }

  Future<void> connectRTC() async {}

  Future<void> disconnectRTC() async {}

  @override
  void dispose() {
    _homeSubscription.cancel();
    super.dispose();
  }
}
