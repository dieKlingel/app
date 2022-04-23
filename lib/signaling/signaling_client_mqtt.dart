import 'package:dieklingel_app/event/event_emitter.dart';

import 'signaling_client.dart';
import 'signaling_message.dart';

class SignalingClientMqtt extends EventEmitter implements SignalingClient {
  @override
  String identifier = "";

  @override
  void connect(String url) {
    // TODO: implement connect
  }

  @override
  void send(SignalingMessage message) {
    // TODO: implement send
  }
}
