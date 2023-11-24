import 'package:blueprint/blueprint.dart';
import 'package:dieklingel_app/models/messages/session_message_header.dart';

import 'session_message_body.dart';

class AnswerMessage {
  final SessionMessageHeader header;
  final SessionMessageBody body;

  AnswerMessage({
    required this.header,
    required this.body,
  });

  factory AnswerMessage.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "header": MapF,
        "body": MapF,
      },
      throwable: true,
    );

    return AnswerMessage(
      header: SessionMessageHeader.fromMap(map["header"]),
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
