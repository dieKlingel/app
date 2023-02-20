import 'dart:async';

import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

class IceServerListViewBloc extends Bloc {
  late final StreamSubscription _subscription;
  final _servers = BehaviorSubject<List<HiveIceServer>>();

  Stream<List<HiveIceServer>> get servers => _servers.stream;

  IceServerListViewBloc() {
    Box<HiveIceServer> box = Hive.box((IceServer).toString());
    _subscription = box.watch().listen((event) {
      _servers.add(box.values.toList());
    });
    _servers.add(box.values.toList());
  }

  @override
  void dispose() {
    _subscription.cancel();
    _servers.close();
  }
}
