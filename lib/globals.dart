library dieklingel_app.globals;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'components/connection_configuration.dart';
import 'components/ice_server.dart';

late SharedPreferences _preferences;

Future<void> init() async {
  _preferences = await SharedPreferences.getInstance();
}

SharedPreferences get preferences {
  return _preferences;
}

List<ConnectionConfiguration> get connectionConfigurations {
  List<String> rawConnectionConfig =
      preferences.getStringList("configuration") ??
          List<String>.empty(growable: true);
  List<ConnectionConfiguration> connectionConfigurations = rawConnectionConfig
      .map(
        (config) => ConnectionConfiguration.fromJson(
          jsonDecode(config),
        ),
      )
      .toList(growable: true);
  return connectionConfigurations;
}

set connectionConfigurations(
  List<ConnectionConfiguration> connectionConfiurations,
) {
  List<String> rawConnectionConfigurations = connectionConfiurations
      .map(
        (config) => config.toString(),
      )
      .toList();
  preferences.setStringList("configuration", rawConnectionConfigurations);
}

ConnectionConfiguration get defaultConnectionConfiguration {
  List<ConnectionConfiguration> configurations = connectionConfigurations;
  ConnectionConfiguration connectionConfiguration = configurations.firstWhere(
      (config) => config.isDefault,
      orElse: (() => configurations.first));
  return connectionConfiguration;
}

/* List<IceConfiguration> get iceConfigurations {
  List<String> rawIceConfig =
      preferences.getStringList("ice") ?? List<String>.empty(growable: true);
  List<IceConfiguration> iceConfigurations = rawIceConfig
      .map(
        (config) => IceConfiguration.fromJson(
          jsonDecode(config),
        ),
      )
      .toList(growable: true);
  if (iceConfigurations.isEmpty) {
    iceConfigurations.add(
      IceConfiguration(
        urls: "stun:stun1.l.google.com:19302",
      ),
    );
    iceConfigurations = iceConfigurations;
  }
  return iceConfigurations;
}

set iceConfigurations(
  List<IceConfiguration> iceConfiurations,
) {
  List<String> rawIceConfigurations = iceConfiurations
      .map(
        (config) => config.toString(),
      )
      .toList();
  preferences.setStringList("ice", rawIceConfigurations); 
} */
