import 'dart:async';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:rxdart/rxdart.dart';

class HomeViewBloc extends Bloc {
  final _home = BehaviorSubject<HiveHome>();

  StreamController<Home> get home => _home;

  @override
  void dispose() {
    _home.close();
  }
}
