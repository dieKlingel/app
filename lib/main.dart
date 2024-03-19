import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' as f;
import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'ui/views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configPath = path.join(
    (await getApplicationSupportDirectory()).path,
    "linphonerc-debug-15-36",
  );
  final Core core = Factory.instance.createCore(configPath: configPath);
  // Do not autoiterate, because its not threadsafe
  core.enableAutoIterate(false);
  final pushConfig = core.getPushNotificationConfig();
  pushConfig.setProvider("apns.dev");
  pushConfig.setBundleIdentifier("com.dieklingel.app");
  pushConfig.setTeamId("3QLZPMLJ3W");
  // do not use enablePushNotification. For the reason see ios/Runner/AppDelegate.swift
  core.enablePushNotification(false);

  Timer.periodic(const Duration(milliseconds: 20), (timer) {
    core.iterate();
  });
  if (Platform.isIOS) {
    core.enableCallkit(true);
  }
  if (f.kDebugMode) {
    core.getPushNotificationConfig().setProvider("apns.dev");
  }

  runApp(
    App(core: core),
  );
}

class App extends StatefulWidget {
  const App({
    Key? key,
    required this.core,
  }) : super(key: key);

  final Core core;

  @override
  State<App> createState() => _App();
}

class _App extends State<App> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state $state");
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    widget.core.start();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeView(core: widget.core),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
