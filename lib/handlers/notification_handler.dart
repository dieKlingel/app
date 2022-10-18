import 'package:dieklingel_app/extensions/get_mclient.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../rtc/rtc_client.dart';

Future<void> onBackgroundNotificationReceived(RemoteMessage message) async {
  String? host = message.data["host"];
  int port = int.tryParse(message.data["port"].toString()) ?? -1;
  String? channel = message.data["channel"];

  if (null == host ||
      host.isEmpty ||
      port <= 0 ||
      null == channel ||
      channel.isEmpty) {
    print("message without MqttRtcDescription");
    return;
  }

  MqttRtcDescription description = MqttRtcDescription(
    host: "wss://server.dieklingel.com",
    port: 9002,
    channel: "com.dieklingel/mayer/kai/rtc/test",
  );

  CallHandler handler = CallHandler.getInstance();
  String uuid = const Uuid().v4();
  MClient mClient = MClient(
      mqttRtcDescription: MqttRtcDescription(
    host: "server.dieklingel.com",
    port: 1883,
  ));

  await mClient.connect();
  String? result = await mClient.get(
    "com.dieklingel/mayer/kai/request/rtc/test",
    description.toString(),
  );
  if (null == result) {
    print("no answer");
    return;
  }

  MqttRtcClient mqttRtcClient = MqttRtcClient.invite(
    MqttRtcDescription(
      host: "server.dieklingel.com",
      port: 1883,
      channel: "com.dieklingel/mayer/kai/rtc/test",
    ),
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
