import 'dart:async';

import 'package:flutter/material.dart';

import '../models/home.dart';

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
