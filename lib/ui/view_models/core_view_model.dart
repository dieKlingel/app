import 'package:dieklingel_app/models/hive_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

class CoreViewModel extends ChangeNotifier {
  final HiveHome home;
  final Client client;

  bool _isConnected = false;
  String? _connectionErrorMessage;

  CoreViewModel(this.home, this.client) {
    connect();
  }

  bool get isConnected {
    return _isConnected;
  }

  String? get connectionErrorMessage {
    return _connectionErrorMessage;
  }

  void connect() async {
    _isConnected = false;
    _connectionErrorMessage = null;
    notifyListeners();

    try {
      await client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
      );
    } on mqtt.NoConnectionException catch (exception) {
      _connectionErrorMessage = exception.toString();
      notifyListeners();
      return;
    }

    _isConnected = true;
    notifyListeners();
  }
}
