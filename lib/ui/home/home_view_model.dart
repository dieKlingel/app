import 'dart:convert';

import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/messages/availability_message.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  final Map<String, mqtt.Client> _connections = {};

  HomeViewModel(this.homeRepository) {
    homeRepository.added.listen((home) async {
      final client = mqtt.Client(home.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[home.id] = client;
      notifyListeners();

      await connect(home);
    });

    homeRepository.changed.listen((home) async {
      final (oldHome, newHome) = home;
      await disconnect(oldHome);

      final client = mqtt.Client(newHome.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[newHome.id] = client;
      notifyListeners();

      await connect(newHome);
    });

    homeRepository.removed.listen((home) async {
      await disconnect(home);

      _connections.remove(home.id);
      notifyListeners();
    });

    for (final home in homeRepository.homes) {
      final client = mqtt.Client(home.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[home.id] = client;

      reconnect(home);
    }
  }

  List<Home> get homes {
    return homeRepository.homes;
  }

  mqtt.ConnectionState state(Home home) {
    return _connections[home.id]!.state;
  }

  Future<void> connect(Home home) async {
    final connection = _connections[home.id];
    if (connection == null) {
      return;
    }

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

  Future<void> disconnect(Home home) async {
    final connection = _connections[home.id];
    if (connection == null) {
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

  void reconnect(Home home) async {
    await disconnect(home);
    await connect(home);
  }

  mqtt.Client client(Home home) {
    return _connections[home.id]!;
  }
}
