import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:hive/hive.dart';

class MqttUriAdapter extends TypeAdapter<MqttUri> {
  @override
  MqttUri read(BinaryReader reader) {
    Map<String, dynamic> map = reader.readMap().cast<String, dynamic>();
    MqttUri uri = MqttUri.fromMap(map);

    return uri;
  }

  @override
  int get typeId => 3;

  @override
  void write(BinaryWriter writer, MqttUri obj) {
    Map<dynamic, dynamic> map = obj.toMap();
    writer.writeMap(map);
  }
}
