import 'dart:convert';

import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/messages/availability_message.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;

  Home? _home;
  mqtt.Client? _client;

  HomeViewModel(this.homeRepository) {
    homeRepository.added.listen((home) => notifyListeners());
    homeRepository.changed.listen((home) => notifyListeners());
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

  mqtt.ConnectionState get state {
    return _client?.state ?? mqtt.ConnectionState.faulted;
  }

  Future<void> connect() async {
    final home = _home;
    if (home == null) {
      return;
    }
    _client ??= mqtt.Client(home.uri);
    final connection = _client!;

    connection.onConnectionStateChanged = (_) {
      notifyListeners();
    };

    await connection.connect(
      username: home.username ?? "",
      password: home.password ?? "",
      throws: false,
      disconnectMessage: mqtt.DisconnectMessage(
        "${home.username}/state",
        retain: true,
        jsonEncode(AvailabilityMessage(
          username: home.username ?? "",
          online: false,
        ).toMap()),
      ),
    );
    connection.publish(
      "${home.username}/state",
      jsonEncode(AvailabilityMessage(
        username: home.username ?? "",
        online: true,
      ).toMap()),
      retain: true,
    );
  }

  Future<void> disconnect() async {
    final connection = _client;
    final home = _home;
    if (connection == null || home == null) {
      return;
    }

    if (connection.state != mqtt.ConnectionState.connected) {
      return;
    }

    connection.publish(
      "${home.username}/state",
      jsonEncode(AvailabilityMessage(
        username: home.username ?? "",
        online: false,
      ).toMap()),
      retain: true,
    );
    // Cooldown
    await Future.delayed(const Duration(milliseconds: 100));
    connection.disconnect();
  }

  void reconnect() async {
    await disconnect();
    await connect();
  }
}
