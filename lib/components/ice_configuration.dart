import 'dart:convert';

import 'package:flutter/foundation.dart';

class IceConfiguration {
  final Key key;
  String urls;
  String username;
  String credential;

  IceConfiguration({
    required this.urls,
    this.username = "",
    this.credential = "",
  }) : key = UniqueKey();

  IceConfiguration.fromJson(Map<String, dynamic> json)
      : key = Key(json['_key']),
        urls = json['urls'],
        username = json['username'],
        credential = json['credential'];

  Map<String, dynamic> toJson() => {
        '_key': key.toString(),
        'urls': urls,
        'username': username,
        'credential': credential,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  bool operator ==(Object other) {
    if (other is! IceConfiguration) {
      return false;
    }
    return (other.key == key);
  }

  @override
  int get hashCode => urls.hashCode;
}
