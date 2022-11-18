import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectdb/objectdb.dart';
import 'package:uuid/uuid.dart';

import '../components/home.dart';

class HomeViewModel extends ChangeNotifier {
  Set<Home> _homes = {};
  String? _uuid;
  ObjectDB? _db;

  HomeViewModel() {
    _init();
  }

  void _init() async {
    _db = await ObjectDBFactory.named("homes");
    await _db!.remove({"uuid": null});
    List<Map<dynamic, dynamic>> result = await _db!.find({});
    _homes = result
        .map((e) => e.cast<String, dynamic>())
        .map((e) => Home.fromMap(e))
        .toSet();
    notifyListeners();
  }

  List<Home> get homes => List.unmodifiable(_homes);

  Home? get home {
    if (_uuid == null) return null;
    for (Home home in homes) {
      if (home.uuid == _uuid) {
        return home;
      }
    }
    return null;
  }

  set home(Home? home) {
    if (home != null) {
      if (home.uuid == null) {
        home = home.copyWith(uuid: const Uuid().v4());
        insert(home);
      }
    }
    _uuid = home?.uuid;
    notifyListeners();
  }

  void insert(Home home) async {
    if (_db == null) return;
    if (home.uuid == null) {
      home = home.copyWith(uuid: const Uuid().v4());
    }

    _homes.remove(home);
    _homes.add(home);

    int result = await _db!.update(
      {
        "uuid": home.uuid,
      },
      home.toMap(),
    );
    if (result < 1) {
      await _db!.insert(home.toMap());
    }
    notifyListeners();
  }

  void delete(Home home) async {
    if (_db == null) return;
    if (home.uuid == null) return;
    _homes.remove(home);
    await _db!.remove(
      {
        "uuid": home.uuid,
      },
    );

    notifyListeners();
  }
}
