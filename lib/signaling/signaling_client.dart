import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../event/event_emitter.dart';
import '../signaling/signaling_message.dart';

class SignalingClient extends EventEmitter {
  WebSocketChannel? _socket;
  String identifier = "";

  WebSocketChannel createSocket(String url, EventEmitter emitter) {
    WebSocketChannel socket = WebSocketChannel.connect(Uri.parse(url));
    socket.stream.listen((event) {
      SignalingMessage message = SignalingMessage.fromJson(jsonDecode(event));
      if (message.to == "") {
        emitter.emit("broadcast", message);
      } else if (message.to == identifier) {
        emitter.emit("message", message);
      }
    });
    return socket;
  }

  void connect(String url) {
    _socket?.sink.close();
    _socket = createSocket(url, this);
  }

  void send(SignalingMessage message) {
    //print("send");
    //print(jsonEncode(message.toJson()));
    _socket?.sink.add(jsonEncode(message));
  }
}
