import 'dart:async';
import 'dart:io';

import 'package:dieklingel_app/extensions/get_mclient.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

import '../rtc/rtc_client.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
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

  String uuid = const Uuid().v4();

  MqttRtcDescription rtcDescription = MqttRtcDescription(
    host: "wss://server.dieklingel.com",
    port: 9002,
    channel: "${mclient.mqttRtcDescription!.channel}rtc/$uuid",
  );

  CallHandler handler = CallHandler.getInstance();

  String? result = await mclient.get(
    "request/rtc/test/",
    rtcDescription.toString(),
  );

  mclient.disconnect();

  if (null == result) {
    print("no answer");
    return;
  }

  MqttRtcDescription localDescription = MqttRtcDescription(
    host: mclient.mqttRtcDescription!.host,
    port: mclient.mqttRtcDescription!.port,
    channel: rtcDescription.channel,
  );

  MqttRtcClient mqttRtcClient = MqttRtcClient.invite(
    localDescription,
    MediaRessource(),
  );
  await mqttRtcClient.mediaRessource.open(true, false);
  await mqttRtcClient.init(iceServers: {
    "iceServers": [
      {"url": "stun:stun1.l.google.com:19302"},
      {
        "urls": "turn:dieklingel.com:3478",
        "username": "guest",
        "credential": "12345"
      },
      {"urls": "stun:openrelay.metered.ca:80"},
      {
        "urls": "turn:openrelay.metered.ca:80",
        "username": "openrelayproject",
        "credential": "openrelayproject"
      },
      {
        "urls": "turn:openrelay.metered.ca:443",
        "username": "openrelayproject",
        "credential": "openrelayproject"
      },
      {
        "urls": "turn:openrelay.metered.ca:443?transport=tcp",
        "username": "openrelayproject",
        "credential": "openrelayproject"
      }
    ],
    "sdpSemantics": "unified-plan" // important to work
  }, transceivers: [
    RtcTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      direction: TransceiverDirection.SendRecv,
    ),
    RtcTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      direction: TransceiverDirection.RecvOnly,
    ),
  ]);
  handler.calls[uuid] = mqttRtcClient;

  await handler.callkeep.displayIncomingCall(
    uuid,
    "0123456789",
    localizedCallerName: "Kai",
    handleType: "generic",
    hasVideo: false,
  );
  handler.callkeep.backToForeground();
}

class NotificationHandler {
  NotificationHandler._();

  static void init() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationReceived);
    FirebaseMessaging.onMessage.listen(onBackgroundNotificationReceived);
  }
}
