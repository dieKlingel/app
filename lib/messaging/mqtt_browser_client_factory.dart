import 'package:flutter/foundation.dart';
import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class MqttClientFactory {
  static MqttClient create(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) {
    MqttClient client = MqttBrowserClient(
      server,
      clientIdentifier,
      maxConnectionAttempts: maxConnectionAttempts,
    );
    if (kIsWeb) {
      // TODO: check if working on web
      //cant connect without next line
      // client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    return client;
  }
}
