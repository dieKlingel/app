class Device {
  final String token;
  final List<String> signs;

  Device(this.token, {this.signs = const []});

  Map<String, dynamic> toMap() {
    return {
      "token": token,
      "signs": signs,
    };
  }
}
