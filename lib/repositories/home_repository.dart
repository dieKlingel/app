import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/home.dart';

class HomeRepository {
  final Box<Home> _homebox = Hive.box((Home).toString());
  final _add = StreamController<Home>.broadcast();
  final _remove = StreamController<Home>.broadcast();
  final _change = StreamController<Home>.broadcast();

  List<Home> get homes => _homebox.values.toList();
  Stream<Home> get added => _add.stream;
  Stream<Home> get changed => _change.stream;
  Stream<Home> get removed => _remove.stream;

  Future<void> add(Home home) async {
    final exists = _homebox.containsKey(home.id);
    await _homebox.put(home.id, home);
    if (exists) {
      _change.add(home);
    } else {
      _add.add(home);
    }
  }

  Future<void> delete(Home home) async {
    _homebox.delete(home.id);
    _remove.add(home);
  }
}
