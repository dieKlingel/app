import 'package:blueprint/blueprint.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CandidateMessageBody {
  final RTCIceCandidate iceCandidate;

  CandidateMessageBody({required this.iceCandidate});

  factory CandidateMessageBody.fromMap(dynamic map) {
    matchMap(
      map,
      {
        "iceCandidate": MapF.of({
          "candidate": StringF,
          "sdpMid": StringF,
          "sdpMLineIndex": IntF,
        }),
      },
      throwable: true,
    );

    return CandidateMessageBody(
      iceCandidate: RTCIceCandidate(
        map["iceCandidate"]["candidate"],
        map["iceCandidate"]["sdpMid"],
        map["iceCandidate"]["sdpMLineIndex"],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "iceCandidate": iceCandidate.toMap(),
    };
  }
}
