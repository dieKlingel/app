import 'package:blueprint/blueprint.dart';

class SessionMessageHeader {
  final String senderDeviceId;
  final String sessionId;
  final String senderSessionId;

  SessionMessageHeader({
    required this.senderDeviceId,
    required this.sessionId,
    required this.senderSessionId,
  });

  factory SessionMessageHeader.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "senderDeviceId": StringF,
        "sessionId": StringF,
        "senderSessionId": StringF,
      },
      throwable: true,
    );

    return SessionMessageHeader(
      senderDeviceId: map["senderDeviceId"],
      sessionId: map["sessionId"],
      senderSessionId: map["senderSessionId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderDeviceId": senderDeviceId,
      "sessionId": sessionId,
      "senderSessionId": senderSessionId,
    };
  }
}
