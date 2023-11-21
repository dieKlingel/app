import 'package:dieklingel_app/blocs/home_add_view_bloc.dart';
import 'package:dieklingel_app/ui/home/home_view_model.dart';
import 'package:dieklingel_app/handlers/notification_handler.dart';
import 'package:dieklingel_app/models/device.dart';
import 'package:dieklingel_app/models/request.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/ui/home/home_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import './models/home.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'blocs/ice_server_add_view_bloc.dart';
import 'firebase_options.dart';
import 'hive/hive_home_adapter.dart';
import 'hive/hive_ice_server_adapter.dart';
import 'models/hive_home.dart';
import 'models/hive_ice_server.dart';
import 'models/ice_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(HiveHomeAdapter())
    ..registerAdapter(HiveIceServerAdapter());

  await Future.wait([
    Hive.openBox<HiveHome>((Home).toString()),
    Hive.openBox<HiveIceServer>((IceServer).toString()),
    Hive.openBox("settings"),
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  HomeRepository homeRepository = HomeRepository();
  IceServerRepository iceServerRepository = IceServerRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => homeRepository),
        RepositoryProvider(create: (_) => iceServerRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeAddViewBloc(homeRepository)),
          BlocProvider(
              create: (_) => IceServerAddViewBloc(iceServerRepository)),
        ],
        child: const App(),
      ),
    ),
  );
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
    await NotificationHandler.init();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
    String? token = await FirebaseMessaging.instance.getToken();
    if (null == token) {
      return;
    }

    Box settingsBox = Hive.box("settings");
    settingsBox.put("token", token);

    Box<HiveHome> box = Hive.box<HiveHome>((Home).toString());
    for (HiveHome home in box.values) {
      final client = Client(home.uri);
      await client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
      );
      await client.publish(
        path.normalize("./${home.uri.path}/devices/save"),
        Request.withJsonBody(
          "GET",
          Device(
            token,
            signs: [home.uri.fragment],
          ).toMap(),
        ).toJsonString(),
      );
      client.disconnect();
    }
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
      home: ChangeNotifierProvider(
        create: (_) => HomeViewModel(context.read<HomeRepository>()),
        child: const HomeView(),
      ),
    );
  }
}
