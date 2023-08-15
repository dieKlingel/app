import 'package:dieklingel_app/models/home.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveHome extends Home with HiveObjectMixin {
  HiveHome({
    required super.name,
    required super.uri,
    super.username,
    super.password,
  });

  factory HiveHome.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey("name")) {
      throw "Cannot create Home from Map without name";
    }
    if (!map.containsKey("uri")) {
      throw "Cannot create Home from Map without uri";
    }

    return HiveHome(
      name: map["name"],
      uri: Uri.parse(map["uri"]),
      username: map["username"],
      password: map["password"],
    );
  }

  @override
  Future<void> save() async {
    if (isInBox) {
      await super.save();
      return;
    }
    Box<HiveHome> box = Hive.box<HiveHome>((Home).toString());
    await box.add(this);
  }
}
