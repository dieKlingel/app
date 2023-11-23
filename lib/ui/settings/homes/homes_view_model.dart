import 'package:dieklingel_app/components/stream_subscription_mixin.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/home.dart';

class HomesViewModel extends ChangeNotifier with StreamHandlerMixin {
  final HomeRepository homeRepository;

  HomesViewModel(this.homeRepository) {
    streams.subscribe(
      homeRepository.added,
      (Home home) => notifyListeners(),
    );
    streams.subscribe(
      homeRepository.changed,
      (Home home) => notifyListeners(),
    );
    streams.subscribe(
      homeRepository.removed,
      (Home home) => notifyListeners(),
    );
  }

  List<Home> get homes {
    return homeRepository.homes;
  }

  void deleteHome(Home home) {
    homeRepository.delete(home);
  }

  @override
  void dispose() {
    streams.dispose();
    super.dispose();
  }
}
