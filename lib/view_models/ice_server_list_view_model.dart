import 'dart:async';

import 'package:dieklingel_app/models/ice_server.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class IceServerListViewModel extends ChangeNotifier {
  late final StreamSubscription _subscription;

  IceServerListViewModel() {
    _subscription = IceServer.boxx.watch().listen((event) {
      notifyListeners();
    });
  }

  List<IceServer> get servers => IceServer.boxx.values.toList();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
