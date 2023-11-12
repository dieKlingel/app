import 'dart:async';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/home.dart';

class HomeRepository {
  final Box<HiveHome> _homebox = Hive.box((Home).toString());
  final _add = StreamController<Home>();
  final _remove = StreamController<Home>();
  final _change = StreamController<Home>();

  List<HiveHome> get homes => _homebox.values.toList();
  Stream<Home> get added => _add.stream;
  Stream<Home> get changed => _change.stream;
  Stream<Home> get removed => _remove.stream;

  Future<void> add(HiveHome home) async {
    if (home.isInBox) {
      await home.save();
      _change.add(home);
      return;
    }
    await _homebox.add(home);
    _add.add(home);
  }

  Future<void> delete(HiveHome home) async {
    if (!home.isInBox) {
      return;
    }
    await home.delete();
    _remove.add(home);
  }
}
