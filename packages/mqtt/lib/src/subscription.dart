import 'client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;

typedef Callback = void Function(String topic, String message);

class Subscription {
  final Client client;
  final Callback callback;
  final mqtt.Subscription subscription;

  Subscription(this.client, this.callback, this.subscription);

  void cancel() {
    client.unsubscribe(this);
  }
}
