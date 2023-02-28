import 'dart:async';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  if (message.data.containsKey("call") &&
      message.data["call"].toString().toLowerCase() == "true") {
    FlutterCallkitIncoming.onEvent.listen(_callevent);
    _call(message);
    return;
  }
  _notification(message);
}

void _callevent(CallEvent? event) {
  switch (event!.event) {
    case Event.ACTION_CALL_INCOMING:
      // TODO: received an incoming call
      break;
    case Event.ACTION_CALL_START:
      // TODO: started an outgoing call
      // TODO: show screen calling in Flutter
      break;
    case Event.ACTION_CALL_ACCEPT:
      // end call, cause we are not able to connect callkit with webrtc call
      FlutterCallkitIncoming.endAllCalls();
      // TODO: accepted an incoming call
      // TODO: show screen calling in Flutter
      break;
    case Event.ACTION_CALL_DECLINE:
      // TODO: declined an incoming call
      break;
    case Event.ACTION_CALL_ENDED:
      // TODO: ended an incoming/outgoing call
      break;
    case Event.ACTION_CALL_TIMEOUT:
      // TODO: missed an incoming call
      break;
    case Event.ACTION_CALL_CALLBACK:
      // TODO: only Android - click action `Call back` from missed call notification
      break;
    case Event.ACTION_CALL_TOGGLE_HOLD:
      // TODO: only iOS
      break;
    case Event.ACTION_CALL_TOGGLE_MUTE:
      // TODO: only iOS
      break;
    case Event.ACTION_CALL_TOGGLE_DMTF:
      // TODO: only iOS
      break;
    case Event.ACTION_CALL_TOGGLE_GROUP:
      // TODO: only iOS
      break;
    case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
      // TODO: only iOS
      break;
    case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
      // TODO: only iOS
      break;
  }
}

Future<void> _call(RemoteMessage message) async {
  String uuid = const Uuid().v4();

  CallKitParams params = CallKitParams(
    id: uuid,
    nameCaller: "dieKlingel",
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
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
