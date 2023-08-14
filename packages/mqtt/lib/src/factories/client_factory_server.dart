import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

mqtt.MqttClient factory(
  String hostname,
  String identifier, {
  int maxConnectionAttempts = 3,
}) {
  mqtt.MqttClient client = MqttServerClient(
    hostname,
    identifier,
    maxConnectionAttempts: maxConnectionAttempts,
  );

  return client;
}
