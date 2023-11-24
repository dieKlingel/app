import 'package:blueprint/blueprint.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SessionMessageBody {
  final RTCSessionDescription sessionDescription;

  SessionMessageBody({
    required this.sessionDescription,
  });

  factory SessionMessageBody.fromMap(Map<String, dynamic> map) {
    matchMap(
      map,
      {
        "sessionDescription": MapF.of({
          "type": StringF,
          "sdp": StringF,
        })
      },
      throwable: true,
    );

    return SessionMessageBody(
      sessionDescription: RTCSessionDescription(
        map["sessionDescription"]["sdp"],
        map["sessionDescription"]["type"],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sessionDescription": sessionDescription.toMap(),
    };
  }
}
