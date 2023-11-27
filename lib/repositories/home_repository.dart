import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/home.dart';

class HomeRepository {
  final Box<Home> _homebox = Hive.box((Home).toString());
  final _add = StreamController<Home>.broadcast();
  final _remove = StreamController<Home>.broadcast();
  final _change = StreamController<(Home, Home)>.broadcast();

  List<Home> get homes => _homebox.values.toList();
  Stream<Home> get added => _add.stream;
  Stream<(Home, Home)> get changed => _change.stream;
  Stream<Home> get removed => _remove.stream;

  Future<void> add(Home home) async {
    final oldHome = _homebox.get(home.id);
    await _homebox.put(home.id, home);

    if (oldHome != null) {
      _change.add((oldHome, home));
    } else {
      _add.add(home);
    }
  }

  Future<void> delete(Home home) async {
    await _homebox.delete(home.id);
    _remove.add(home);
  }
}
