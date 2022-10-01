import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class TouchScrollBehavior extends CupertinoScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
