import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_core_shared/models/ice_server.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class IceServerRepository extends ChangeNotifier {
  final Box<HiveIceServer> _serverbox = Hive.box((IceServer).toString());

  List<HiveIceServer> get servers => _serverbox.values.toList();

  Future<void> add(HiveIceServer server) async {
    await _serverbox.add(server);
    notifyListeners();
  }

  Future<void> delete(HiveIceServer server) async {
    if (!server.isInBox) {
      return;
    }
    await server.delete();
    notifyListeners();
  }
}
