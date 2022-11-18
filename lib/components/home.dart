import 'dart:convert';

import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:flutter/cupertino.dart';

class Home {
  final String? uuid;
  final String name;
  final MqttRtcDescription description;
  final String? username;
  final String? password;

  factory Home.fromMap(Map<String, dynamic> map) => Home(
        uuid: map["uuid"],
        name: map["name"],
        description: MqttRtcDescription.fromMap(map["description"]),
        username: map["username"],
        password: map["password"],
      );

  Home({
    this.uuid,
    required this.name,
    required this.description,
    this.username,
    this.password,
  });

  Home copyWith({
    String? uuid,
    String? name,
    MqttRtcDescription? description,
    String? username,
    String? password,
  }) =>
      Home(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        description: description ?? this.description,
        username: username ?? this.username,
        password: this.password,
      );

  Map<String, dynamic> toMap() {
    return {
      "uuid": uuid,
      "name": name,
      "description": description.toMap(),
      "username": username,
      "password": password,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }

  @override
  bool operator ==(Object other) {
    if (other is! Home) {
      return false;
    }
    if (uuid == null || other.uuid == null) {
      return false;
    }
    return uuid == other.uuid;
  }

  @override
  int get hashCode => Key(uuid ?? super.hashCode.toString()).hashCode;
}
