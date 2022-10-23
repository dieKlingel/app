import 'dart:async';

import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:uuid/uuid.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  CallHandler handler = CallHandler.getInstance();
  String uuid = const Uuid().v4().toUpperCase();

  String? title = message.notification?.title;
  String? body = message.notification?.body;
  String? descriptions = message.data["mqtt-rtc-descriptions"];

  Preferences preferences = await Preferences.getInstance();

  if (!(preferences.getBool("incomming_call_enabled") ?? true) &&
      (null != title || null != body)) {
    print("display local notification");
    return;
  }

  if (null != descriptions) {
    List<Uri> uris = descriptions
        .split(";")
        .map<Uri>(
          (e) => Uri.parse(e),
        )
        .toList();

    Completer<MClient> completer = Completer<MClient>();
    for (Uri uri in uris) {
      MClient client =
          MClient(mqttRtcDescription: MqttRtcDescription.parse(uri));

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
  }
}

class NotificationHandler {
  NotificationHandler._();

  static void init() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationReceived);
    FirebaseMessaging.onMessage.listen(onBackgroundNotificationReceived);
  }
}
