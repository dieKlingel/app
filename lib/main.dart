import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/injectable/dependecies.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/ice_server.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/view_models/homes_view_model.dart';
import 'package:dieklingel_app/views/homes_view.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependecies();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(HomeAdapter())
    ..registerAdapter(IceServerAdapter());

  await Future.wait([
    Hive.openBox<MqttUri>((MqttUri).toString()),
    Hive.openBox<Home>((Home).toString()),
    Hive.openBox<IceServer>((IceServer).toString()),
    Hive.openBox("settings"),
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
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
    //context.read<Preferences>().setString("firebase_token", token);
  }

  void publishFirebaseToken() {
    // TODO: publish token
    /* String? firebaseToken = context.read<AppSettings>().firebaseToken.value;
    if (context.read<MClientImpl>().connectionState !=
            MqttConnectionState.connected ||
        null == firebaseToken) {
      return;
    }
    Map<String, dynamic> message = {
      "hash": "#default",
      "token": firebaseToken,
    };
    print("publish");
     context.read<MClientImpl>().publish(
          MClientTopicMessage(
            topic: "firebase/notification/token/add",
            message: jsonEncode(message),
          ),
        );*/
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: HomesView(),
    );
  }
}
