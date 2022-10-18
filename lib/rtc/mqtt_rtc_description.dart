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

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
