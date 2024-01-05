import 'package:dieklingel_app/components/stream_subscription_mixin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationsViewModel extends ChangeNotifier with StreamHandlerMixin {
  late final Box _store = Hive.box("notification_service:settings");

  NotificationsViewModel() {
    streams.subscribe(
      FirebaseMessaging.instance.onTokenRefresh,
      (token) async {
        await _store.put("notification_service:token", token);
        notifyListeners();
      },
    );

    () async {
      if (enabled) {
        final token = await FirebaseMessaging.instance.getToken();
        await _store.put("notification_service:token", token);
        notifyListeners();
      }
    }();
  }

  set enabled(bool enabled) {
    _store.put("notification_service:enabled", enabled).then((_) {
      notifyListeners();
    });

    () async {
      if (enabled) {
        final permission = await FirebaseMessaging.instance.requestPermission();
        if (permission.authorizationStatus != AuthorizationStatus.authorized) {
          await _store.put("notification_service:enabled", false);
          notifyListeners();
          return;
        }

        final token = await FirebaseMessaging.instance.getToken();
        await _store.put("notification_service:token", token);
        notifyListeners();
      } else {
        await _store.delete("notification_service:token");
        await FirebaseMessaging.instance.deleteToken();
        notifyListeners();
      }
    }();
  }

  bool get enabled {
    return _store.get("notification_service:enabled", defaultValue: false);
  }

  String? get token {
    return _store.get("notification_service:token");
  }

  @override
  void dispose() {
    streams.dispose();
    super.dispose();
  }
}
