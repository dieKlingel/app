import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@singleton
class RtcService {
  final Map<String, MqttRtcClient> _connecting = {};

  String startRTC(MqttUri uri) {
    String uuid = const Uuid().v4();
    _startRTC(
      uuid: uuid,
      uri: uri,
      ressource: GetIt.I.get<MediaRessource>(),
    );

    return uuid;
  }

  Future<void> _startRTC({
    required String uuid,
    required MqttUri uri,
    required MediaRessource ressource,
  }) async {
    MqttRtcClient client = MqttRtcClient.invite(uri, ressource);
    _connecting[uuid] = client;

    
  }

  void endRTC(String uuid) async {
    throw UnimplementedError();
  }
}
