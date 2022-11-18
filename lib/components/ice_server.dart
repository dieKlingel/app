import 'dart:convert';

class IceServer {
  final String? uuid;
  final String urls;
  final String username;
  final String credential;

  IceServer({
    this.uuid,
    required this.urls,
    this.username = "",
    this.credential = "",
  });

  IceServer.fromMap(Map<String, dynamic> json)
      : uuid = json['uuid'],
        urls = json['urls'],
        username = json['username'],
        credential = json['credential'];

  Map<String, dynamic> toMap() => {
        'uuid': uuid,
        'urls': urls,
        'username': username,
        'credential': credential,
      };

  @override
  String toString() {
    return jsonEncode(toMap());
  }

  @override
  bool operator ==(Object other) {
    if (other is! IceServer) {
      return false;
    }
    if (uuid == null) {
      return false;
    }
    return other.uuid == uuid;
  }

  @override
  int get hashCode => urls.hashCode;
}
