library dieklingel_app.globals;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'components/connection_configuration.dart';

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
