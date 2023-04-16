import 'package:mqtt/models/mqtt_uri.dart';

class Home {
  String name;
  MqttUri uri;
  String? username;
  String? password;

  Home({
    required this.name,
    required this.uri,
    this.username,
    this.password,
  });

  factory Home.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey("name")) {
      throw "Cannot create Home from Map without name";
    }
    if (!map.containsKey("uri")) {
      throw "Cannot create Home from Map without uri";
    }

    return Home(
      name: map["name"],
      uri: MqttUri.fromMap(map["uri"]),
      username: map["username"],
      password: map["password"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uri": uri.toMap(),
      "username": username,
      "password": password,
    };
  }

  Home copy() {
    return copyWith();
  }

  Home copyWith({
    String? name,
    MqttUri? uri,
    String? username,
    String? password,
  }) =>
      Home(
        name: name ?? this.name,
        uri: uri ?? this.uri,
        username: username ?? this.username,
        password: this.password,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Home) {
      return false;
    }
    return name == other.name &&
        uri == other.uri &&
        username == other.username &&
        password == other.password;
  }

  @override
  int get hashCode => Object.hash(name, uri, username, password);

  @override
  String toString() {
    return "Home -> name: $name";
  }
}
