import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../models/home.dart';

@injectable
class HomeLiveViewModel extends ChangeNotifier {
  MqttRtcClient get client => throw UnimplementedError();

  void connect(Home home) {
    throw UnimplementedError();
  }

  void disconnect(Home home) {
    throw UnimplementedError();
  }
}
