import 'package:blueprint/blueprint.dart';

class MessageHeader {
  final String senderDeviceId;
  final String sessionId;

  MessageHeader({
    required this.senderDeviceId,
    required this.sessionId,
  });

  factory MessageHeader.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "senderDeviceId": StringF,
        "sessionId": StringF,
      },
      throwable: true,
    );

    return MessageHeader(
      senderDeviceId: map["senderDeviceId"],
      sessionId: map["sessionId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderDeviceId": senderDeviceId,
      "sessionId": sessionId,
    };
  }
}
