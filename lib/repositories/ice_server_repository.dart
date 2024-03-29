import 'package:hive_flutter/hive_flutter.dart';

import '../models/hive_ice_server.dart';
import '../models/ice_server.dart';

class IceServerRepository {
  final Box<HiveIceServer> _serverbox = Hive.box((IceServer).toString());

  List<HiveIceServer> get servers => _serverbox.values.toList();

  Future<void> add(HiveIceServer server) async {
    if (server.isInBox) {
      await server.save();
      return;
    }
    await _serverbox.add(server);
  }

  Future<void> delete(HiveIceServer server) async {
    if (!server.isInBox) {
      return;
    }
    await server.delete();
  }
}
