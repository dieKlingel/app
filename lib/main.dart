import 'package:dieklingel_app/ui/views/account_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'ui/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Core core = Factory.instance.createCore();

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
      home: AccountView(core: widget.core), //HomeView(core: widget.core),
    );
  }
}
