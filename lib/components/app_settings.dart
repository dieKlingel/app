import '../components/notifyable_value.dart';
import 'package:flutter/material.dart';

import '../components/connection_configuration.dart';
import 'ice_server.dart';
import '../components/notifyable_list.dart';

class AppSettings extends ChangeNotifier {
  //final NotifyableList<IceConfiguration> iceConfigurations =
  //    NotifyableList<IceConfiguration>();

  final NotifyableList<ConnectionConfiguration> connectionConfigurations =
      NotifyableList<ConnectionConfiguration>();

  final NotifyableValue<String?> firebaseToken =
      NotifyableValue<String?>(value: null);

  AppSettings() {
    //iceConfigurations.addListener(notifyListeners);
    connectionConfigurations.addListener(notifyListeners);
  }
}
