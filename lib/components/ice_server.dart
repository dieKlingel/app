import 'dart:convert';

class IceServer {
  final String urls;
  final String username;
  final String credential;

  IceServer({
    required this.urls,
    this.username = "",
    this.credential = "",
  });

  IceServer.fromJson(Map<String, dynamic> json)
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

  @override
  bool operator ==(Object other) {
    if (other is! IceServer) {
      return false;
    }
    return other.urls == urls &&
        other.username == username &&
        other.credential == credential;
  }

  @override
  int get hashCode => urls.hashCode;
}
