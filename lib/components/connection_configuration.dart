import 'dart:convert';

import 'package:flutter/material.dart';

class ConnectionConfiguration {
  final Key key;
  String description;
  String url;
  String? username;
  String? password;
  String? channelPrefix;
  bool isDefault;

  ConnectionConfiguration({
    this.description = "",
    this.url = "",
    this.channelPrefix,
    this.username,
    this.password,
    this.isDefault = false,
  }) : key = UniqueKey();

  ConnectionConfiguration.fromJson(Map<String, dynamic> json)
      : key = Key(json['_key']),
        description = json['description'],
        url = json['url'],
        username = json['username'],
        password = json['password'],
        channelPrefix = json['channel_prefix'],
        isDefault = json['isDefault'];

  Map<String, dynamic> toJson() => {
        '_key': key.toString(),
        'description': description,
        'url': url,
        'username': username,
        'password': password,
        'channel_prefix': channelPrefix,
        'isDefault': isDefault,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  bool operator ==(Object other) {
    if (other is! ConnectionConfiguration) {
      return false;
    }
    return (other.key == key);
  }

  @override
  int get hashCode => description.hashCode;
}
