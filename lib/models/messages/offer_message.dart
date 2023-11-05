import 'package:blueprint/blueprint.dart';

import 'message_header.dart';
import 'session_message_body.dart';

class OfferMessage {
  final MessageHeader header;
  final SessionMessageBody body;

  OfferMessage({
    required this.header,
    required this.body,
  });

  factory OfferMessage.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "header": MapF,
        "body": MapF,
      },
      throwable: true,
    );

    return OfferMessage(
      header: MessageHeader.fromMap(map["header"]),
      body: SessionMessageBody.fromMap(map["body"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "header": header.toMap(),
      "body": body.toMap(),
    };
  }
}
