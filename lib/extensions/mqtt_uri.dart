import 'package:mqtt/models/mqtt_uri.dart';

extension HostOnly on MqttUri {
  Uri toHostOnlyUri() {
    String scheme = websocket
        ? ssl
            ? "wss"
            : "ws"
        : ssl
            ? "mqtts"
            : "mqtt";
    return Uri(
      host: host,
      port: port,
      scheme: scheme,
    );
  }

  String toHostOnlyString() {
    return toHostOnlyUri().toString();
  }
}
