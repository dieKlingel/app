import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:callkeep/callkeep.dart';
import 'package:flutter/material.dart';

import '../components/notifyable_map.dart';

class CallHandler extends ChangeNotifier {
  static final CallHandler _instance = CallHandler._();
  factory CallHandler.getInstance() => _instance;

  final NotifyableMap<String, MqttRtcClient> calls =
      NotifyableMap<String, MqttRtcClient>();
  final FlutterCallkeep callkeep = FlutterCallkeep();
  final MClient mClient = MClient();
  late final Future<void> callkeepIsReady;

  String? _activeCallUuid;

  String? get activeCallUuid {
    return _activeCallUuid;
  }

  set activeCallUuid(String? uuid) {
    _activeCallUuid = uuid;
    notifyListeners();
  }

  CallHandler._() {
    calls.addListener(notifyListeners);
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
        //active[uuid] =
        activeCallUuid = uuid;

        notifyListeners();
      },
    );
    callkeep.on(
      CallKeepPerformEndCallAction(),
      (CallKeepPerformEndCallAction event) {
        String? uuid = event.callUUID;
        if (null == uuid) return;
        activeCallUuid = null;

        calls[uuid]?.close();
        calls.remove(uuid);

        notifyListeners();
      },
    );

    callkeep.on(
      CallKeepDidReceiveStartCallAction(),
      (CallKeepDidReceiveStartCallAction event) {
        print("start call");
      },
    );

    callkeep.on(
      CallKeepDidToggleHoldAction(),
      (CallKeepDidToggleHoldAction event) {
        String? uuid = event.callUUID;
        bool? hold = event.hold;
        print("toogle $uuid $hold");
        if (null == uuid || null == hold) return;

        if (activeCallUuid == uuid) {
          if (hold) {
            activeCallUuid = null;
          } else {
            activeCallUuid = uuid;
          }
        }
        /* if (!calls.containsKey(uuid)) return;
        calls[uuid]!.close();
        calls.remove(uuid); */

        notifyListeners();
      },
    );
  }
}
