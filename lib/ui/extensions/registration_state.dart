import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

extension RegistrationStateExt on RegistrationState {
  Widget? get indicator {
    switch (this) {
      case RegistrationState.none:
        return null;
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
