import 'package:blueprint/blueprint.dart';

import 'session_message_header.dart';

class CloseMessage {
  final SessionMessageHeader header;

  CloseMessage({
    required this.header,
  });

  factory CloseMessage.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "header": MapF,
      },
      throwable: true,
    );

    return CloseMessage(
      header: SessionMessageHeader.fromMap(map["header"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "header": header.toMap(),
    };
  }
}
