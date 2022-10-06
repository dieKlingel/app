import 'dart:convert';

import 'package:dieklingel_app/messaging/mclient_subscribtion.dart';
import 'package:dieklingel_app/messaging/mclient_topic_message.dart';
import 'package:flutter/material.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'mqtt_server_client_factory.dart'
    if (dart.library.js) 'mqtt_browser_client_factory.dart';

class MClient extends ChangeNotifier {
  final List<MClientSubscribtion> _subscribtions = [];
  String? prefix;
  String? host;
  int? port;
  MqttClient? _mqttClient;

  MClient({
    this.host,
    this.port,
    this.prefix,
  });

  MqttConnectionState get connectionState {
    return _mqttClient?.connectionStatus?.state ??
        MqttConnectionState.disconnected;
  }

  Future<MqttConnectionStatus?> connect({
    String? username,
    String? password,
  }) async {
    if (null == host) throw "cannot connect mclient without host";
    if (null == port) throw "cannot connect mclient without port";
    _mqttClient?.disconnect();

    _mqttClient = MqttClientFactory.create(host!, "");
    _mqttClient!.port = port!;
    _mqttClient!.keepAlivePeriod = 20;
    _mqttClient!.onConnected = () {
      print("connected");
      notifyListeners();
    };
    _mqttClient!.onDisconnected = () {
      print("disconnected");
      notifyListeners();
    };

    try {
      await _mqttClient!.connect(username, password);
    } catch (exception) {
      return null;
    }

    _mqttClient!.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      MqttPublishMessage rec = c[0].payload as MqttPublishMessage;
      String topic = c[0].topic!;
      if (null != prefix && topic.startsWith(prefix!)) {
        topic.replaceFirst(prefix!, "");
      }
      List<int> messageAsBytes = rec.payload.message!;
      String raw = utf8.decode(messageAsBytes);
      MClientTopicMessage message = MClientTopicMessage(
        topic: topic,
        message: raw,
      );
      for (MClientSubscribtion sub in _subscribtions) {
        sub.listener(message);
      }
    });

    return _mqttClient!.connectionStatus;
  }

  void publish(MClientTopicMessage message) {
    if (connectionState != MqttConnectionState.connected) {
      throw "the mqtt client has to be connected, before publish";
    }
    MqttPayloadBuilder builder = MqttPayloadBuilder();
    builder.addString(message.message);
    _mqttClient!.publishMessage(
      message.topic,
      MqttQos.exactlyOnce,
      builder.payload!,
    );
  }

  MClientSubscribtion subscribe(
    String topic,
    void Function(MClientTopicMessage message) listener,
  ) {
    MClientSubscribtion subscribtion =
        MClientSubscribtion("$prefix$topic", listener: listener);
    _subscribtions.add(subscribtion);
    _mqttClient?.subscribe(topic, MqttQos.exactlyOnce);
    return subscribtion;
  }

  void unsubscribe(MClientSubscribtion subscribtion) {
    _subscribtions.remove(subscribtion);
    for (int i = 0; i < _subscribtions.length; i++) {
      if (_subscribtions[i].topic == subscribtion.topic) {
        return;
      }
    }
    _mqttClient?.unsubscribeStringTopic(subscribtion.topic);
  }

  void disconnect() {
    _mqttClient?.disconnect();
    _mqttClient = null;
  }
}
