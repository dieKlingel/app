import 'dart:async';

import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:uuid/uuid.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  CallHandler handler = CallHandler.getInstance();
  String uuid = const Uuid().v4().toUpperCase();

  String? descriptions = message.data["mqtt-rtc-descriptions"];
  if (null == descriptions) {
    print("no descriptions");
    return;
  }
  List<Uri> uris = descriptions
      .split(";")
      .map<Uri>(
        (e) => Uri.parse(e),
      )
      .toList();

  Completer<MClient> completer = Completer<MClient>();
  for (Uri uri in uris) {
    MClient client = MClient(mqttRtcDescription: MqttRtcDescription.parse(uri));

    client.connect().then(
      (value) {
        if (completer.isCompleted) {
          client.disconnect();
          return;
        }
        completer.complete(client);
      },
    ).catchError(
      (error) {
        client.disconnect();
      },
    );
  }
  Future.delayed(const Duration(seconds: 10), () {
    if (!completer.isCompleted) {
      completer.completeError(Object());
    }
  });

  MClient mclient;
  try {
    mclient = await completer.future;
  } catch (e) {
    /* timeout */
    return;
  }

  handler.requested[uuid] = mclient;
  await FlutterVoipKit.reportIncomingCall(handle: "01772727", uuid: uuid);
  Future.delayed(const Duration(seconds: 10), () {
    mclient.disconnect();
  });
  //mclient.disconnect();
}

class NotificationHandler {
  NotificationHandler._();

  static void init() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationReceived);
    FirebaseMessaging.onMessage.listen(onBackgroundNotificationReceived);
  }
}
