import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

mqtt.MqttClient factory(
  Uri host,
  String identifier, {
  int maxConnectionAttempts = 3,
}) {
  final client = MqttServerClient(
    host.host,
    identifier,
    maxConnectionAttempts: maxConnectionAttempts,
  );

  if (host.scheme == "mqtts") {
    client.secure = true;
  }

  return client;
}
