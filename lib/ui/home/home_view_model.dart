import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/tunnel/tunnel.dart';
import 'package:dieklingel_app/models/tunnel/tunnel_state.dart';

import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;

  Home? _home;
  Tunnel? _tunnel;

  HomeViewModel(this.homeRepository) {
    homeRepository.added.listen((home) => notifyListeners());
    homeRepository.changed.listen((home) {
      notifyListeners();
      if (home.$1.id != _home?.id) {
        return;
      }

      disconnect();
      this.home = home.$2;
      connect();
    });
    homeRepository.removed.listen((home) => notifyListeners());

    _home = homeRepository.homes.firstOrNull;
    connect();
  }

  set home(Home? home) {
    _home = home;
    notifyListeners();
  }

  Home? get home {
    return _home;
  }

  List<Home> get homes {
    return homeRepository.homes;
  }

  TunnelState get state {
    return _tunnel?.state ?? TunnelState.disconnected;
  }

  Future<void> connect() async {
    final home = _home;
    if (home == null) {
      return;
    }

    final tunnel = Tunnel(
      home.uri,
      username: home.username ?? "",
      password: home.password ?? "",
    );
    _tunnel = tunnel;

    tunnel.onStateChanged = (_) {
      notifyListeners();
    };

    await tunnel.connect();
  }

  Future<void> disconnect() async {
    final tunnel = _tunnel;
    final home = _home;
    if (tunnel == null || home == null) {
      return;
    }

    await tunnel.disconnect();
  }

  void reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(milliseconds: 200));
    await connect();
  }
}
