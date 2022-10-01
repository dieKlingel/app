import 'package:flutter/material.dart';

import '../components/connection_configuration.dart';
import '../components/ice_configuration.dart';
import '../components/notifyable_list.dart';

class AppSettings extends ChangeNotifier {
  final NotifyableList<IceConfiguration> iceConfigurations =
      NotifyableList<IceConfiguration>();

  final NotifyableList<ConnectionConfiguration> connectionConfigurations =
      NotifyableList<ConnectionConfiguration>();

  AppSettings() {
    iceConfigurations.addListener(notifyListeners);
    connectionConfigurations.addListener(notifyListeners);
  }
}
