import 'package:blueprint/blueprint.dart';

class MessageHeader {
  final String senderDeviceId;
  final String senderSessionId;

  MessageHeader({
    required this.senderDeviceId,
    required this.senderSessionId,
  });

  factory MessageHeader.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "senderDeviceId": StringF,
        "senderSessionId": StringF,
      },
      throwable: true,
    );

    return MessageHeader(
      senderDeviceId: map["senderDeviceId"],
      senderSessionId: map["senderSessionId"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderDeviceId": senderDeviceId,
      "senderSessionId": senderSessionId,
    };
  }
}
