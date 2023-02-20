import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive/hive.dart';

class IceServerAdapter extends TypeAdapter<IceServer> {
  @override
  IceServer read(BinaryReader reader) {
    Map<String, dynamic> map = reader.readMap().cast<String, dynamic>();

    IceServer server = IceServer.fromMap(map);
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
