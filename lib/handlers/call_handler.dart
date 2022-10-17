import 'dart:ffi';

import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:callkeep/callkeep.dart';
import 'package:flutter/material.dart';

class CallHandler extends ChangeNotifier {
  static final CallHandler _instance = CallHandler._();
  factory CallHandler.getInstance() => _instance;

  final Map<String, MqttRtcClient> calls = {};
  final FlutterCallkeep callkeep = FlutterCallkeep();
  final MClient mClient = MClient();
  late final Future<void> callkeepIsReady;

  CallHandler._() {
    _initCallkeep();
  }

  void _initCallkeep() {
    Map<String, dynamic> options = {
      'ios': {
        'appName': 'dieKlingel',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'Ok',
        // Required to get audio in background when using Android 11
        'foregroundService': {
          'channelId': 'com.company.my',
          'channelName': 'Foreground service for my app',
          'notificationTitle': 'My app is running on background',
          'notificationIcon': 'mipmap/ic_notification_launcher',
        },
      },
    };
    callkeepIsReady = callkeep.setup(null, options, backgroundMode: true);

    callkeep.on(
      CallKeepPerformAnswerCallAction(),
      (CallKeepPerformAnswerCallAction event) {
        String? uuid = event.callUUID;
        if (null == uuid) return;
        if (!calls.containsKey(uuid)) return;

        calls[uuid]!.open();
      },
    );
    callkeep.on(
      CallKeepPerformEndCallAction(),
      (CallKeepPerformEndCallAction event) {
        String? uuid = event.callUUID;
        if (null == uuid) return;
        if (!calls.containsKey(uuid)) return;

        calls[uuid]!.close();
        calls.remove(uuid);
      },
    );
  }
}
