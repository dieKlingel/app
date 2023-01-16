import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:flutter/material.dart';

import '../models/home.dart';

class HomeLiveViewModel extends ChangeNotifier {
  MqttRtcClient get client => throw UnimplementedError();

  void connect(Home home) {
    throw UnimplementedError();
  }

  void disconnect(Home home) {
    throw UnimplementedError();
  }
}
