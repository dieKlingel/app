import 'package:blueprint/blueprint.dart';
import 'package:dieklingel_app/models/messages/candidate_message_body.dart';
import 'package:dieklingel_app/models/messages/session_message_header.dart';

class CandidateMessage {
  final SessionMessageHeader header;
  final CandidateMessageBody body;

  CandidateMessage({
    required this.header,
    required this.body,
  });

  factory CandidateMessage.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "header": MapF,
        "body": MapF,
      },
      throwable: true,
    );

    return CandidateMessage(
      header: SessionMessageHeader.fromMap(map["header"]),
      body: CandidateMessageBody.fromMap(map["body"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "header": header.toMap(),
      "body": body.toMap(),
    };
  }
}
