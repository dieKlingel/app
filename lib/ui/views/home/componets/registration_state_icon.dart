import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

class RegistrationStateIcon extends StatelessWidget {
  final RegistrationState state;

  const RegistrationStateIcon({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RegistrationState.none:
        return Container();
      case RegistrationState.refreshing:
      case RegistrationState.progress:
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      case RegistrationState.ok:
        return const Icon(Icons.check);
      case RegistrationState.cleared:
        return const Icon(Icons.flutter_dash);
      case RegistrationState.failed:
        return const Icon(Icons.error);
    }
  }
}
