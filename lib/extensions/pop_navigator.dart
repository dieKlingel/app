import 'package:flutter/material.dart';

extension PopNavigator on Navigator {
  static void popRootAndReplace(BuildContext context, Route<dynamic> newRoute) {
    Navigator.popUntil(context, (route) {
      if (!route.isFirst) {
        Navigator.replaceRouteBelow(
          context,
          anchorRoute: route,
          newRoute: newRoute,
        );
      }
      return route.isFirst;
    });
  }
}
