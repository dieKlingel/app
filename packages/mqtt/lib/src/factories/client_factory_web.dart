import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

mqtt.MqttClient factory(
  String hostname,
  String identifier, {
  int maxConnectionAttempts = 3,
}) {
  mqtt.MqttClient client = MqttBrowserClient(
    hostname,
    identifier,
    maxConnectionAttempts: maxConnectionAttempts,
  );

  if (kIsWeb) {
    client.websocketProtocols = mqtt.MqttClientConstants.protocolsSingleDefault;
  }

  return client;
}
