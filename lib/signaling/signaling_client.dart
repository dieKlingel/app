import 'package:dieklingel_app/event/event_emitter.dart';
import 'package:dieklingel_app/signaling/signaling_message.dart';

abstract class SignalingClient extends EventEmitter {
  String identifier = "";
  void connect(String url);
  void send(SignalingMessage message);
}
