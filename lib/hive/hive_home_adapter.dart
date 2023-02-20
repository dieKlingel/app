import 'package:dieklingel_app/models/home.dart';
import 'package:hive/hive.dart';

import '../models/hive_home.dart';

class HiveHomeAdapter extends TypeAdapter<HiveHome> {
  @override
  HiveHome read(BinaryReader reader) {
    Map<String, dynamic> map = reader.readMap().cast<String, dynamic>();

    HiveHome home = HiveHome.fromMap(map);
    return home;
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, Home obj) {
    Map<dynamic, dynamic> map = obj.toMap();
    writer.writeMap(map);
  }
}
