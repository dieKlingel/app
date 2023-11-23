import 'package:dieklingel_app/models/home.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  final Map<String, mqtt.Client> _connections = {};

  HomeViewModel(this.homeRepository) {
    homeRepository.added.listen((home) {
      final client = mqtt.Client(home.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[home.id] = client;
      notifyListeners();

      client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );
    });

    homeRepository.changed.listen((home) {
      _connections[home.id]?.disconnect();

      final client = mqtt.Client(home.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[home.id] = client;
      notifyListeners();

      client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );
    });

    homeRepository.removed.listen((home) {
      _connections[home]?.disconnect();
      _connections.remove(home);
      notifyListeners();
    });

    for (final home in homeRepository.homes) {
      final client = mqtt.Client(home.uri);
      client.onConnectionStateChanged = (_) => notifyListeners();
      _connections[home.id] = client;

      client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );
    }
  }

  List<Home> get homes {
    return homeRepository.homes;
  }

  mqtt.ConnectionState state(Home home) {
    return _connections[home.id]!.state;
  }

  void reconnect(Home home) {
    _connections[home.id]?.disconnect();
    _connections[home.id]?.connect(
      username: home.username ?? "",
      password: home.password ?? "",
      throws: false,
    );
  }

  mqtt.Client client(Home home) {
    return _connections[home.id]!;
  }
}
