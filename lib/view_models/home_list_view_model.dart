import 'dart:async';

import 'package:dieklingel_app/models/home.dart';
import 'package:flutter/material.dart';

class HomeListViewModel extends ChangeNotifier {
  late final StreamSubscription _subscription;

  HomeListViewModel() {
    _subscription = Home.boxx.watch().listen((event) {
      notifyListeners();
    });
  }

  List<Home> get homes => Home.boxx.values.toList();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
