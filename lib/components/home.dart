import 'dart:convert';

import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';

class Home {
  final String name;
  final MqttRtcDescription description;
  final String? username;
  final String? password;

  Home({
    required this.name,
    required this.description,
    this.username,
    this.password,
  });

  Home.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = MqttRtcDescription.fromJson(json["description"]),
        username = json['username'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description.toJson(),
        'username': username,
        'password': password,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
