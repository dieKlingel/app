import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/hive_ice_server.dart';

class HiveIceServerAdapter extends TypeAdapter<HiveIceServer> {
  @override
  HiveIceServer read(BinaryReader reader) {
    Map<String, dynamic> map = reader.readMap().cast<String, dynamic>();

    HiveIceServer server = HiveIceServer.fromMap(map);
    return server;
  }

  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, IceServer obj) {
    Map<dynamic, dynamic> map = obj.toMap();
    writer.writeMap(map);
  }
}
