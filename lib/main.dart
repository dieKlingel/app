import 'dart:convert';

import 'package:dieklingel_app/handlers/notification_handler.dart';

import 'components/notifyable_value.dart';
import 'messaging/mclient_topic_message.dart';
import 'rtc/rtc_client.dart';
import 'components/app_settings.dart';
import 'messaging/mclient.dart';
import 'signaling/signaling_client.dart';
import 'views/home_view_page.dart';
import 'components/connection_configuration.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

import './views/settings/connection_configuration_view.dart';
import 'globals.dart' as app;

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  NotificationHandler.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await app.init();
  MClient mClient = MClient();
  mClient.prefix = "com.dieklingel/mayer/kai/";
  SignalingClient signalingClient = SignalingClient.fromMessagingClient(
    mClient,
    signalingTopic: "rtc/signaling",
  );
  AppSettings appSettings = AppSettings();
  NotifyableValue<RtcClient?> rtcClient = NotifyableValue(value: null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => mClient),
        ChangeNotifierProvider(create: (context) => signalingClient),
        ChangeNotifierProvider(create: (context) => appSettings),
        ChangeNotifierProvider(create: (context) => rtcClient),
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
    return context.read<AppSettings>().connectionConfigurations.isEmpty
        ? null
        : context.read<AppSettings>().connectionConfigurations.firstWhere(
              (element) => element.isDefault,
              orElse: () =>
                  context.read<AppSettings>().connectionConfigurations.first,
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
    if (context.read<MClient>().connectionState !=
            MqttConnectionState.connected ||
        null == firebaseToken) {
      return;
    }
    Map<String, dynamic> message = {
      "hash": "#default",
      "token": firebaseToken,
    };
    print("publish");
    context.read<MClient>().publish(
          MClientTopicMessage(
            topic: "firebase/notification/token/add",
            message: jsonEncode(message),
          ),
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
        context.read<MClient>().host =
            "${kIsWeb ? "${defaultConfig.uri?.scheme}://" : ""}${defaultConfig.uri?.host}";
        context.read<MClient>().port = defaultConfig.uri?.port;
        context.read<MClient>().prefix = defaultConfig.channelPrefix ?? "";
        context.read<MClient>().disconnect();
        await context.read<MClient>().connect(
              username: defaultConfig.username,
              password: defaultConfig.password,
            );
        if (!mounted) return;
        publishFirebaseToken();
        /* context
            .read<MClient>()
            .listen("rtc/signaling")
            .listen("io/camera/snapshot");*/
      },
    );

    context
        .read<AppSettings>()
        .iceConfigurations
        .replace(app.iceConfigurations);
    context.read<AppSettings>().iceConfigurations.addListener(() {
      app.iceConfigurations =
          context.read<AppSettings>().iceConfigurations.asList();
    });

    context
        .read<AppSettings>()
        .connectionConfigurations
        .replace(app.connectionConfigurations);
    context.read<AppSettings>().connectionConfigurations.addListener(() {
      app.connectionConfigurations =
          context.read<AppSettings>().connectionConfigurations.asList();
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
