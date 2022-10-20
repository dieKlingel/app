import 'dart:convert';

import 'package:dieklingel_app/database/objectdb_factory.dart';

class MqttRtcDescription {
  final String host;
  final int port;
  final String channel;
  final bool ssl;
  final bool websocket;

  MqttRtcDescription({
    required this.host,
    required this.port,
    this.channel = "",
    this.ssl = true,
    this.websocket = false,
  });

  factory MqttRtcDescription.fromJson(JSON json) {
    return MqttRtcDescription(
      host: json["host"],
      port: json["port"],
      channel: json["channel"],
      ssl: json["ssl"].toString() != "false",
      websocket: json["websocket"].toString() == "true",
    );
  }

  factory MqttRtcDescription.parse(Uri uri) {
    return MqttRtcDescription(
      host: uri.host,
      port: uri.port,
      channel: uri.path.substring(1),
      ssl: uri.scheme == "mqtts" || uri.scheme == "wss",
      websocket: uri.scheme == "ws" || uri.scheme == "wss",
    );
  }

  JSON toJson() {
    return {
      "host": host,
      "port": port,
      "channel": channel,
    };
  }

  Uri toUri() {
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
      path: channel,
      scheme: scheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! MqttRtcDescription) return false;
    return hashCode == other.hashCode;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  int get hashCode => toUri().hashCode;
}
