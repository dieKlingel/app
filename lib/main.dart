import 'dart:convert';

import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/handlers/call_handler.dart';
import 'package:dieklingel_app/handlers/notification_handler.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/ice_server.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/views/home_view.dart';
import 'package:dieklingel_app/view_models/home_view_model.dart';
import 'package:dieklingel_app/views/settings/ice_servers_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:objectdb/objectdb.dart';

import 'messaging/mclient_topic_message.dart';
import 'components/app_settings.dart';
import 'messaging/mclient.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHandler.init();

  await Hive.initFlutter();

  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(HomeAdapter())
    ..registerAdapter(IceServerAdapter());

  await Future.wait([
    Hive.openBox<MqttUri>((MqttUri).toString()),
    Hive.openBox<Home>((Home).toString()),
    Hive.openBox<IceServer>((IceServer).toString()),
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  MClient mclient = MClient();
  Preferences preferences = await Preferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => mclient),
        ChangeNotifierProvider(create: (context) => preferences),
        ChangeNotifierProvider(create: (context) => CallHandler.getInstance()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => IceServersViewModel()),
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
    return true; // app.connectionConfigurations.isNotEmpty;
  }

  /* ConnectionConfiguration? getDefaultConnectionConfiguration() {
    return context.read<AppSettings>().connectionConfigurations.isEmpty
        ? null
        : context.read<AppSettings>().connectionConfigurations.firstWhere(
              (element) => element.isDefault,
              orElse: () =>
                  context.read<AppSettings>().connectionConfigurations.first,
            );
  } */

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
    context.read<Preferences>().setString("firebase_token", token);
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
    /* context.read<AppSettings>().connectionConfigurations.addListener(
      () async {
        ConnectionConfiguration? defaultConfig =
            getDefaultConnectionConfiguration();
        if (defaultConfig == null) return;
        context.read<MClient>().mqttRtcDescription = MqttRtcDescription(
          host: defaultConfig.uri!.host,
          port: defaultConfig.uri!.port,
          channel: "com.dieklingel/mayer/kai",
          websocket: kIsWeb,
          ssl: defaultConfig.uri!.scheme == "mqtts" ||
              defaultConfig.uri!.scheme == "wss",
        );
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
    ); */

    /* context
        .read<AppSettings>()
        .iceConfigurations
        .replace(app.iceConfigurations); */
    /*context.read<AppSettings>().iceConfigurations.addListener(() {
      app.iceConfigurations =
          context.read<AppSettings>().iceConfigurations.asList(); 
    });*/

    /* context
        .read<AppSettings>()
        .connectionConfigurations
        .replace(app.connectionConfigurations);
    context.read<AppSettings>().connectionConfigurations.addListener(() {
      app.connectionConfigurations =
          context.read<AppSettings>().connectionConfigurations.asList();
    }); */
  }

  Future<bool> isInitialized() async {
    ObjectDB db = await ObjectDBFactory.named("homes");
    List<Map<dynamic, dynamic>> result = await db.find({});
    return result.isNotEmpty;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: HomeView(),
    );
  }
}
