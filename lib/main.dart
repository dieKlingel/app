import 'package:dieklingel_app/blocs/homes_view_bloc.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';

import './models/home.dart';
import './views/homes_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'hive/hive_home_adapter.dart';
import 'hive/hive_ice_server_adapter.dart';
import 'hive/mqtt_uri_adapter.dart';
import 'models/hive_home.dart';
import 'models/hive_ice_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MqttUriAdapter())
    ..registerAdapter(HiveHomeAdapter())
    ..registerAdapter(HiveIceServerAdapter());

  await Future.wait([
    Hive.openBox<MqttUri>((MqttUri).toString()),
    Hive.openBox<HiveHome>((Home).toString()),
    Hive.openBox<HiveIceServer>((IceServer).toString()),
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
  }

  void initialize() {
    if (kIsWeb) {
      // TODO: implement push notifications for web
    } else {
      registerFcmPushNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: BlocProvider(
        bloc: HomesViewBloc(),
        child: const HomesView(),
      ),
    );
  }
}
