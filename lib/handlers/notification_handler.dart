import 'dart:async';
import 'dart:math';

import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:uuid/uuid.dart';

import '../messaging/mclient.dart';
import '../models/mqtt_uri.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  Preferences preferences = await Preferences.getInstance();
  bool incommingCall = preferences.getBool("incomming_call_enabled") ?? true;

  if (incommingCall) {
    _call(message);
  } else {
    _notification(message);
  }
}

Future<void> _call(RemoteMessage message) async {
  CallHandler handler = CallHandler.getInstance();
  String uuid = const Uuid().v4().toUpperCase();
  String caller = message.data["caller"] ?? "dieKlingel";
  String? descriptions = message.data["mqtt-rtc-descriptions"];

  if (null == descriptions) return;

  List<Uri> uris = descriptions
      .split(";")
      .map<Uri>(
        (e) => Uri.parse(e),
      )
      .toList();

  Completer<MClient> completer = Completer<MClient>();
  for (Uri uri in uris) {
    MClient client = MClient();

    client.connect(MqttUri.fromUri(uri)).then(
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

  //handler.requested[uuid] = mclient;
  // handler.prepare(uuid, mclient);
  await FlutterVoipKit.reportIncomingCall(handle: caller, uuid: uuid);
  Future.delayed(const Duration(seconds: 10), () {
    mclient.disconnect();
  });
}

Future<void> _notification(RemoteMessage message) async {
  String? title = message.data["title"];
  String? body = message.data["body"];

  if (null == title || null == body) return;

  FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ),
  );
  int id = Random().nextInt(100);
  await plugin.show(
    id,
    title,
    body,
    const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails("dieklingel", "dieklingle"),
    ),
  );
}

class NotificationHandler {
  NotificationHandler._();

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationReceived);
    FirebaseMessaging.onMessage.listen(onBackgroundNotificationReceived);
  }
}
