import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

mqtt.MqttClient factory(
  Uri host,
  String identifier, {
  int maxConnectionAttempts = 3,
}) {
  String hostname = host.scheme == "wss" || host.scheme == "ws"
      ? "${host.scheme}://${host.host}"
      : host.host;

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
