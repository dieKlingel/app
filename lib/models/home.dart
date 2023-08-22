class Home {
  String name;
  Uri uri;
  String? username;
  String? password;
  String? passcode;

  Home({
    required this.name,
    required this.uri,
    this.username,
    this.password,
    this.passcode,
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
      uri: Uri.parse(map["uri"]),
      username: map["username"],
      password: map["password"],
      passcode: map["passcode"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uri": uri.toString(),
      "username": username,
      "password": password,
      "passcode": passcode,
    };
  }

  Home copy() {
    return copyWith();
  }

  Home copyWith({
    String? name,
    Uri? uri,
    String? username,
    String? password,
    String? passcode,
  }) =>
      Home(
        name: name ?? this.name,
        uri: uri ?? this.uri,
        username: username ?? this.username,
        password: password ?? this.password,
        passcode: passcode ?? this.passcode,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Home) {
      return false;
    }
    return name == other.name &&
        uri == other.uri &&
        username == other.username &&
        password == other.password &&
        passcode == other.passcode;
  }

  @override
  int get hashCode => Object.hash(name, uri, username, password, passcode);

  @override
  String toString() {
    return "Home -> name: $name";
  }
}
