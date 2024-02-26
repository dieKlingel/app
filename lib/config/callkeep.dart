import 'package:flutter_callkeep/flutter_callkeep.dart';

final callKeepBaseConfig = CallKeepBaseConfig(
  appName: "dieKlingel",
  androidConfig: CallKeepAndroidConfig(),
  iosConfig: CallKeepIosConfig(
    supportsDTMF: false,
  ),
);
