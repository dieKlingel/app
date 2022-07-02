import 'dart:convert';

class ConnectionConfiguration {
  final String description;
  final String url;
  final String? username;
  final String? password;
  final String channelPrefix;

  ConnectionConfiguration(
    this.description,
    this.url,
    this.channelPrefix, {
    this.username,
    this.password,
  });

  ConnectionConfiguration.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        url = json['url'],
        username = json['username'],
        password = json['password'],
        channelPrefix = json['channel_prefix'];

  Map<String, dynamic> toJson() => {
        'description': description,
        'url': url,
        'username': username,
        'password': password,
        'channel_prefix': channelPrefix,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
