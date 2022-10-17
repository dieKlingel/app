import 'dart:convert';

import 'package:dieklingel_app/database/objectdb_factory.dart';

class MqttRtcDescription {
  final String host;
  final int port;
  final String channel;

  MqttRtcDescription({
    required this.host,
    required this.port,
    required this.channel,
  });

  factory MqttRtcDescription.fromJson(JSON json) {
    return MqttRtcDescription(
      host: json["host"],
      port: json["port"],
      channel: json["channel"],
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
