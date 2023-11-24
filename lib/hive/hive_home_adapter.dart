import 'package:dieklingel_app/models/home.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveHomeAdapter extends TypeAdapter<Home> {
  @override
  Home read(BinaryReader reader) {
    Map<String, dynamic> map = reader.readMap().cast<String, dynamic>();

    Home home = Home.fromMap(map);
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
