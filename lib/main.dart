import 'package:dieklingel_app/components/app_settings.dart';
import 'package:dieklingel_app/messaging/messaging_client.dart';
import 'package:dieklingel_app/signaling/signaling_client.dart';
import 'package:dieklingel_app/views/home_view_page.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'components/connection_configuration.dart';
import 'firebase_options.dart';

import './views/settings/connection_configuration_view.dart';
import 'globals.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MessagingClient messagingClient = MessagingClient();
  SignalingClient signalingClient =
      SignalingClient.fromMessagingClient(messagingClient);
  AppSettings appSettings = AppSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => messagingClient),
        ChangeNotifierProvider(create: (context) => signalingClient),
        ChangeNotifierProvider(create: (context) => appSettings),
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
    return context.read<AppSettings>().connectionConfigurations.list.isEmpty
        ? null
        : context.read<AppSettings>().connectionConfigurations.list.firstWhere(
              (element) => element.isDefault,
              orElse: () => context
                  .read<AppSettings>()
                  .connectionConfigurations
                  .list
                  .first,
            );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initialize());
  }

  void initialize() {
    context.read<AppSettings>().connectionConfigurations.addListener(
      () async {
        ConnectionConfiguration? defaultConfig =
            getDefaultConnectionConfiguration();
        if (defaultConfig == null) return;
        context.read<MessagingClient>().hostname = defaultConfig.uri?.host;
        context.read<MessagingClient>().port = defaultConfig.uri?.port;
        context.read<MessagingClient>().prefix =
            defaultConfig.channelPrefix ?? "";
        context.read<MessagingClient>().disconnect();
        await context.read<MessagingClient>().connect(
              username: defaultConfig.username,
              password: defaultConfig.password,
            );
        if (!mounted) return;
        context.read<MessagingClient>().listen("rtc/signaling");
        context.read<SignalingClient>().signalingTopic = "rtc/signaling";
      },
    );

    context
        .read<AppSettings>()
        .iceConfigurations
        .replaceList(app.iceConfigurations);
    context.read<AppSettings>().iceConfigurations.addListener(() {
      app.iceConfigurations =
          context.read<AppSettings>().iceConfigurations.list;
    });

    context
        .read<AppSettings>()
        .connectionConfigurations
        .replaceList(app.connectionConfigurations);
    context.read<AppSettings>().connectionConfigurations.addListener(() {
      app.connectionConfigurations =
          context.read<AppSettings>().connectionConfigurations.list;
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
