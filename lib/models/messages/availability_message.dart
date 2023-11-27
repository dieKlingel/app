class AvailabilityMessage {
  final String username;
  final String? token;
  final bool online;

  AvailabilityMessage({
    required this.username,
    required this.online,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      "online": isOnline,
      "username": username,
      "token": token,
    };
  }

  bool get isOnline {
    return online;
  }
}
