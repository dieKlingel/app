import 'dart:convert';

import 'package:dieklingel_app/event/event_emitter.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'signaling_client.dart';
import 'signaling_message.dart';

class SignalingClientMqtt extends EventEmitter implements SignalingClient {
  MqttServerClient? client;
  @override
  String identifier = "";
  final String _topic;

  SignalingClientMqtt({String topic = "com.dieklingel.app/default"})
      : _topic = topic;

  Future<MqttServerClient> createSocket(String url) async {
    MqttServerClient client =
        MqttServerClient(url, "com.dieklingel.app.instance");
    client.keepAlivePeriod = 20;
    client.setProtocolV311();

    await client.connect();
    client.subscribe(_topic, MqttQos.exactlyOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      MqttPublishMessage rec = c![0].payload as MqttPublishMessage;
      //String topic = c[0].topic;
      String raw =
          MqttPublishPayload.bytesToStringAsString(rec.payload.message);
      SignalingMessage message = SignalingMessage.fromJson(jsonDecode(raw));
      if (message.to == "") {
        emit("broadcast", message);
      } else if (message.to == identifier) {
        emit("message", message);
      }
    });

    return client;
  }

  @override
  void connect(String url) async {
    client?.disconnect();
    client = await createSocket(url);
  }

  @override
  void send(SignalingMessage message) {
    String raw = jsonEncode(message.toJson());
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(raw);
    client?.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }
}