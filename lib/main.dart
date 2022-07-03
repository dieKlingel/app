import 'package:dieklingel_app/views/home_view.dart';
import 'package:dieklingel_app/views/settings/connection_configuration_view.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> isInitialzied() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> configurations =
        prefs.getStringList("configuration") ?? List<String>.empty();
    return configurations.isNotEmpty;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: FutureBuilder<bool>(
        future: isInitialzied(),
        builder: ((context, snapshot) {
          bool initialized = snapshot.data ?? false;
          return initialized ? const HomeView() : ConnectionConfigurationView();
        }),
      ),
    );
  }
}
