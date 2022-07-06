import 'package:dieklingel_app/components/connection_configuration.dart';
import 'package:dieklingel_app/views/home_view.dart';
import 'package:dieklingel_app/views/settings/connection_configuration_view.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'globals.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  bool get isInitialzied {
    return app.connectionConfigurations.isNotEmpty;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: isInitialzied ? const HomeView() : ConnectionConfigurationView(),
    );
  }
}
