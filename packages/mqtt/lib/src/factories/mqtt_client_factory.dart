import 'package:mqtt_client/mqtt_client.dart';

import 'client_factory_server.dart'
    if (dart.library.js) 'client_factory_web.dart' as f;

class MqttClientFactory {
  const MqttClientFactory();

  MqttClient create(
    String hostname,
    String identifier, {
    int maxConnectionAttempts = 3,
  }) {
    return f.factory(
      hostname,
      identifier,
      maxConnectionAttempts: maxConnectionAttempts,
    );
  }
}
