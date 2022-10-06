import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

class MqttClientFactory {
  static MqttClient create(
    String server,
    String clientIdentifier, {
    int maxConnectionAttempts = 3,
  }) {
    MqttClient client = MqttServerClient(
      server,
      clientIdentifier,
      maxConnectionAttempts: maxConnectionAttempts,
    );
    return client;
  }
}
