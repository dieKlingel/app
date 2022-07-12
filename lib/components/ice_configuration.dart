import 'dart:convert';

class IceConfiguration {
  String urls;
  String username;
  String credential;

  IceConfiguration({
    required this.urls,
    this.username = "",
    this.credential = "",
  });

  IceConfiguration.fromJson(Map<String, dynamic> json)
      : urls = json['urls'],
        username = json['username'],
        credential = json['credential'];

  Map<String, dynamic> toJson() => {
        'urls': urls,
        'username': username,
        'credential': credential,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
