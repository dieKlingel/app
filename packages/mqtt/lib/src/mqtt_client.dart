import 'dart:async';
import 'dart:convert';

import 'factories/mqtt_client_factory.dart';
import 'subscription.dart';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

class MqttClient {
  final Uri _uri;
  final mqtt.MqttClient _client;
  final Map<String, List<Subscription>> _subscriptions = {};

  MqttClient._(this._client, this._uri) {
    _client
      ..port = _uri.port
      ..keepAlivePeriod = 20
      ..setProtocolV311()
      ..autoReconnect = true;
  }

  factory MqttClient(Uri uri, {String? identifier}) {
    String host = uri.scheme == "wss" || uri.scheme == "ws"
        ? "${uri.scheme}://${uri.host}"
        : uri.host;

    final client = const MqttClientFactory().create(
      host,
      identifier ?? const Uuid().v4(),
    );

    return MqttClient._(client, uri);
  }

  void disconnect() {
    _client.disconnect();
  }

  Future<void> connect({String username = "", String password = ""}) async {
    await _client.connect(username, password);
    _client.updates!.listen((event) {
      mqtt.MqttPublishMessage rec = event[0].payload as mqtt.MqttPublishMessage;
      final String topic = event[0].topic;
      List<int> messageAsBytes = rec.payload.message;
      String message = utf8.decode(messageAsBytes);

      for (final entry in _subscriptions.entries) {
        final st = mqtt.SubscriptionTopic(entry.key);
        final pt = mqtt.PublicationTopic(topic);

        if (st.matches(pt)) {
          for (Subscription sub in entry.value) {
            sub.callback(topic, message);
          }
        }
      }
    });
  }

  Subscription subscribe(
    String topic,
    Callback callback, {
    mqtt.MqttQos qosLevel = mqtt.MqttQos.exactlyOnce,
  }) {
    final mqtt.Subscription? sub = _client.subscribe(topic, qosLevel);

    if (sub == null) {
      throw Exception("error while subscribing to $topic");
    }

    final subscription = Subscription(
      this,
      callback,
      sub,
    );

    _subscriptions.putIfAbsent(topic, () => []).add(subscription);
    return subscription;
  }

  void unsubscribe(Subscription subscription) {
    List<Subscription>? subs = _subscriptions[subscription.subscription.topic];
    subs?.remove(subscription);
    if (subs != null && subs.isEmpty) {
      _client.unsubscribe(subscription.subscription.topic.toString());
    }
  }

  void publish(
    String topic,
    String message, {
    mqtt.MqttQos qosLevel = mqtt.MqttQos.exactlyOnce,
  }) {
    _client.publishMessage(
      topic,
      qosLevel,
      mqtt.MqttClientPayloadBuilder().addUTF8String(message).payload!,
    );
  }

  Future<String> once(String topic, {Duration? timeout}) async {
    Completer<String> completer = Completer<String>();
    Subscription subscription = subscribe(topic, (topic, message) {
      completer.complete(message);
    });
    String result;
    if (timeout != null) {
      result = await completer.future.timeout(timeout);
    } else {
      result = await completer.future;
    }
    subscription.cancel();
    return result;
  }
}
