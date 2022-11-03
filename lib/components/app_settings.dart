import 'package:flutter/material.dart';

import '../components/notifyable_value.dart';

class AppSettings extends ChangeNotifier {
  //final NotifyableList<IceConfiguration> iceConfigurations =
  //    NotifyableList<IceConfiguration>();

  /* final NotifyableList<ConnectionConfiguration> connectionConfigurations =
      NotifyableList<ConnectionConfiguration>();*/

  final NotifyableValue<String?> firebaseToken =
      NotifyableValue<String?>(value: null);

  /* AppSettings() {
    //iceConfigurations.addListener(notifyListeners);
    connectionConfigurations.addListener(notifyListeners); 
  } */
}
