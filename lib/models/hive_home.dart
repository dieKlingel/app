import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive/hive.dart';

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

    MqttUri uri = MqttUri.fromMap((map["uri"] as Map<dynamic, dynamic>).cast());

    return HiveHome(
      name: map["name"],
      uri: uri,
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
