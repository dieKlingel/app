import 'ice_server.dart';

import 'package:hive_flutter/hive_flutter.dart';

class HiveIceServer extends IceServer with HiveObjectMixin {
  HiveIceServer({required super.urls, super.username, super.credential});

  factory HiveIceServer.fromMap(Map<String, dynamic> map) {
    return HiveIceServer(
      urls: map["urls"] ?? "",
      username: map["username"] ?? "",
      credential: map["credential"] ?? "",
    );
  }

  @override
  Future<void> save() async {
    if (isInBox) {
      await super.save();
      return;
    }
    Box<HiveIceServer> box = Hive.box<HiveIceServer>((IceServer).toString());
    await box.add(this);
  }
}
