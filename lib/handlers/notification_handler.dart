import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  _notification(message);
}

Future<void> _notification(RemoteMessage message) async {
  String? title = message.data["title"] ?? message.notification?.title;
  String? body = message.data["body"] ?? message.notification?.body;

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
