import 'dart:async';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;

  HomeViewModel(this.homeRepository);

  HiveHome? get home {
    return homeRepository.selected;
  }

  set home(HiveHome? home) {
    (() async {
      await homeRepository.select(home);
      notifyListeners();
    })();
  }

  List<HiveHome> get homes {
    return homeRepository.homes;
  }

  Future<void> refresh() async {
    HiveHome? selected = homeRepository.selected;
    if (selected == null && homeRepository.homes.isNotEmpty) {
      await homeRepository.select(homeRepository.homes.first);
      selected = homeRepository.selected;
    }
    if (selected == home) {
      return;
    }

    notifyListeners();
  }
}
