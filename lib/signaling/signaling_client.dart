import 'dart:async';
import 'dart:convert';

import '../messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';

import '../messaging/mclient.dart';
import 'signaling_message.dart';

class SignalingClient extends ChangeNotifier {
  final MClient _messagingClient;
  String signalingTopic;
  final StreamController<SignalingMessage> messageController =
      StreamController<SignalingMessage>.broadcast();

  Stream<SignalingMessage> get messages => messageController.stream;

  SignalingClient.fromMessagingClient(
    this._messagingClient, {
    required this.signalingTopic,
  }) {
    _messagingClient.subscribe(signalingTopic, (event) {
      if (signalingTopic != event.topic) return;
      try {
        SignalingMessage message =
            SignalingMessage.fromJson(jsonDecode(event.message));

        messageController.add(message);
      } catch (exception) {
        print(
          "could not convert the message into a signaling message;$exception",
        );
      }
    });
  }

  void send(SignalingMessage message) {
    if (signalingTopic == "") {
      throw Exception("the signaling topic cannot be ''");
    }
    String raw = jsonEncode(message.toJson());
    _messagingClient
        .publish(MClientTopicMessage(topic: signalingTopic, message: raw));
  }
}
