import 'package:dieklingel_app/models/home.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository homeRepository;
  final Map<Home, mqtt.Client> _connections = {};

  HomeViewModel(this.homeRepository) {
    homeRepository.added.listen((home) async {
      _connections[home] = mqtt.Client(home.uri);
      await _connections[home]?.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );
      notifyListeners();
    });

    homeRepository.changed.listen((home) async {
      _connections[home]?.disconnect();
      _connections[home] = mqtt.Client(home.uri);
      await _connections[home]?.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );

      notifyListeners();
    });

    homeRepository.removed.listen((home) async {
      _connections[home]?.disconnect();
      _connections.remove(home);
      notifyListeners();
    });

    for (final home in homeRepository.homes) {
      _connections[home] = mqtt.Client(home.uri);
      _connections[home]?.connect(
        username: home.username ?? "",
        password: home.password ?? "",
        throws: false,
      );
    }
  }

  List<Home> get homes {
    return _connections.keys.toList();
  }

  List<(Home, mqtt.Client)> get connections {
    return _connections.entries.map((e) => (e.key, e.value)).toList();
  }
}
