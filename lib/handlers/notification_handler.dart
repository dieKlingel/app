import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  _notification(message);
}

Future<void> _notification(RemoteMessage message) async {
  String? title = message.data["title"] ?? message.notification?.title;
  String? body = message.data["body"] ?? message.notification?.body;
  int id = int.tryParse(message.data["id"] ?? "") ?? Random().nextInt(100);

  if (null == title || null == body) return;

  FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ),
  );

  StyleInformation? styleInformation;

  if (message.data["image"] != null) {
    final http.Response response = await http.get(
      Uri.parse(message.data["imageUrl"]),
    );

    styleInformation = BigPictureStyleInformation(
      ByteArrayAndroidBitmap(response.bodyBytes),
    );
  }

  await plugin.show(
    id,
    title,
    body,
    NotificationDetails(
      iOS: const DarwinNotificationDetails(
        sound: "ringtone.wav",
      ),
      android: AndroidNotificationDetails(
        "dieklingel",
        "dieklingle",
        styleInformation: styleInformation,
      ),
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
