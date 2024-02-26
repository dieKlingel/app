import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'ui/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Core core = Factory.instance.createCore();
  // Do not autoiterate, because its not threadsafe
  core.enableAutoIterate(false);
  Timer.periodic(const Duration(milliseconds: 20), (timer) {
    core.iterate();
  });

  if (Platform.isIOS) {
    core.enableCallkit(true);
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

class _App extends State<App> {
  @override
  void initState() {
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
}
