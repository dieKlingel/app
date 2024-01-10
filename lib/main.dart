import 'package:dieklingel_app/ui/home/home_view_model.dart';

import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/ui/home/home_view.dart';
import 'package:dieklingel_app/ui/settings/homes/homes_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:provider/provider.dart';

import './models/home.dart';
import './handlers/notification_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'blocs/ice_server_add_view_bloc.dart';
import 'firebase_options.dart';
import 'hive/hive_home_adapter.dart';
import 'hive/hive_ice_server_adapter.dart';
import 'models/hive_ice_server.dart';
import 'models/ice_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(HiveHomeAdapter())
    ..registerAdapter(HiveIceServerAdapter());

  await Future.wait([
    Hive.openBox<Home>((Home).toString()),
    Hive.openBox<HiveIceServer>((IceServer).toString()),
    Hive.openBox("settings"),
    Hive.openBox("notification_service:settings")
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
      child: MultiProvider(
        providers: [
          BlocProvider(
            create: (_) => IceServerAddViewBloc(iceServerRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => HomesViewModel(homeRepository),
          )
        ],
        child: const App(),
      ),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
  }

  void initialize() async {
    await NotificationHandler.init();
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
