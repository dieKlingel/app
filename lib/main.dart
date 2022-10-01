import 'dart:convert';

import 'package:dieklingel_app/components/app_settings.dart';
import 'package:dieklingel_app/messaging/messaging_client.dart';
import 'package:dieklingel_app/signaling/signaling_client.dart';
import 'package:dieklingel_app/views/home_view_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'components/connection_configuration.dart';

import './views/settings/connection_configuration_view.dart';
import 'globals.dart' as app;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await app.init();
  MessagingClient messagingClient = MessagingClient();
  SignalingClient signalingClient =
      SignalingClient.fromMessagingClient(messagingClient);
  AppSettings appSettings = AppSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => messagingClient),
        ChangeNotifierProvider(create: (context) => signalingClient),
        ChangeNotifierProvider(create: (context) => appSettings),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  bool get isInitialzied {
    return app.connectionConfigurations.isNotEmpty;
  }

  ConnectionConfiguration? getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.list.isEmpty
        ? null
        : context.read<AppSettings>().connectionConfigurations.list.firstWhere(
              (element) => element.isDefault,
              orElse: () => context
                  .read<AppSettings>()
                  .connectionConfigurations
                  .list
                  .first,
            );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
  }

  void registerFcmPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await FirebaseMessaging.instance.getToken();
    if (null == token) return;
    print("Token: $token");
    if (!mounted) return;
    context.read<AppSettings>().firebaseToken.addListener(publishFirebaseToken);
    context.read<AppSettings>().firebaseToken.value = token;
  }

  void publishFirebaseToken() {
    String? firebaseToken = context.read<AppSettings>().firebaseToken.value;
    if (!context.read<MessagingClient>().isConnected() ||
        null == firebaseToken) {
      return;
    }
    Map<String, dynamic> message = {
      "hash": "#default",
      "token": firebaseToken,
    };
    print("publish");
    context.read<MessagingClient>().send(
          "firebase/notification/token/add",
          jsonEncode(message),
        );
  }

  void initialize() {
    if (kIsWeb) {
      // TODO: implement push notifications for web
    } else {
      registerFcmPushNotifications();
    }
    context.read<AppSettings>().connectionConfigurations.addListener(
      () async {
        ConnectionConfiguration? defaultConfig =
            getDefaultConnectionConfiguration();
        if (defaultConfig == null) return;
        context.read<MessagingClient>().hostname = defaultConfig.uri?.host;
        context.read<MessagingClient>().port = defaultConfig.uri?.port;
        context.read<MessagingClient>().prefix =
            defaultConfig.channelPrefix ?? "";
        context.read<MessagingClient>().disconnect();
        await context.read<MessagingClient>().connect(
              username: defaultConfig.username,
              password: defaultConfig.password,
            );
        if (!mounted) return;
        publishFirebaseToken();
        context.read<MessagingClient>().listen("rtc/signaling");
        context.read<SignalingClient>().signalingTopic = "rtc/signaling";
      },
    );

    context
        .read<AppSettings>()
        .iceConfigurations
        .replaceList(app.iceConfigurations);
    context.read<AppSettings>().iceConfigurations.addListener(() {
      app.iceConfigurations =
          context.read<AppSettings>().iceConfigurations.list;
    });

    context
        .read<AppSettings>()
        .connectionConfigurations
        .replaceList(app.connectionConfigurations);
    context.read<AppSettings>().connectionConfigurations.addListener(() {
      app.connectionConfigurations =
          context.read<AppSettings>().connectionConfigurations.list;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home:
          isInitialzied ? const HomeViewPage() : ConnectionConfigurationView(),
    );
  }
}
