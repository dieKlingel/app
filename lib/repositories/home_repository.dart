import 'package:dieklingel_app/models/hive_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/home.dart';

class HomeRepository extends ChangeNotifier {
  final Box<HiveHome> _homebox = Hive.box((Home).toString());
  final Box _settingsbox = Hive.box("settings");

  List<HiveHome> get homes => _homebox.values.toList();

  HiveHome? get selected {
    dynamic key = _settingsbox.get("home");
    if (key == null) {
      return null;
    }
    if (!_homebox.containsKey(key) && _homebox.isNotEmpty) {
      select(_homebox.values.first);
      return _homebox.values.first;
    }
    return _homebox.get(key);
  }

  Future<void> add(HiveHome home) async {
    await _homebox.add(home);
    notifyListeners();
  }

  Future<void> delete(HiveHome home) async {
    if (!home.isInBox) {
      return;
    }
    await home.delete();
    if (homes.isEmpty) {
      await select(null);
      return;
    }
    if (selected == home) {
      select(homes.first);
    }
    notifyListeners();
  }

  Future<void> select(HiveHome? home) async {
    if (home == null) {
      await _settingsbox.delete("home");
      notifyListeners();
      return;
    }
    if (!homes.contains(home)) {
      throw Exception(
        "The selected home cannot be selected, because it is not saved!",
      );
    }
    await _settingsbox.put("home", home.key);
    notifyListeners();
  }
}
