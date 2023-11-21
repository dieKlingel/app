import 'package:flutter/cupertino.dart';

class FadePageRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;

  FadePageRoute({required this.builder})
      : super(
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secAnimaton) {
            return builder(context);
          },
          transitionsBuilder: (context, animation, secAnimation, child) {
            final tween = Tween(begin: 0.0, end: 1.0);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.ease,
            );

            return FadeTransition(
              opacity: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}
