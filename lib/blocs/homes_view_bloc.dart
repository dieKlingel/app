import 'dart:async';

import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

import '../models/hive_home.dart';
import '../models/home.dart';

class HomesViewBloc extends Bloc {
  late final StreamSubscription _subscription;
  final _homes = BehaviorSubject<List<HiveHome>>();

  Stream<List<HiveHome>> get homes => _homes.stream;

  HomesViewBloc() {
    Box<HiveHome> box = Hive.box((Home).toString());
    _subscription = box.watch().listen((event) {
      _homes.add(box.values.toList());
    });
    _homes.add(box.values.toList());
  }

  @override
  void dispose() {
    _subscription.cancel();
    _homes.close();
    // TODO: implement dispose
  }
}
