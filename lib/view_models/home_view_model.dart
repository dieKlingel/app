import 'dart:async';

import 'package:dieklingel_app/messaging/mclient_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../messaging/mclient.dart';
import '../models/home.dart';

@injectable
class HomeViewModel extends ChangeNotifier {
  late final StreamSubscription _homeSubscription;
  late final MClient _client;

  HomeViewModel() : _client = GetIt.I.get<MClient>() {
    _homeSubscription = Home.boxx.watch().listen((event) {
      notifyListeners();
    });
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
    notifyListeners();
  }

  Future<MClientState> connect() async {
    Home? home = this.home;
    if (home == null) {
      return MClientState.disconnected;
    }
    await _client.disconnect();
    await _client.connect(
      home.uri,
      username: home.username ?? "",
      password: home.password ?? "",
    );
    return _client.state;
  }

  @override
  void dispose() {
    _homeSubscription.cancel();
    super.dispose();
  }
}
