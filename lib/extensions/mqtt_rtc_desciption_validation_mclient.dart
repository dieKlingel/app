import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_description.dart';
import 'package:mqtt_client/mqtt_client.dart';

extension MqttRtcDescriptionValidation on MClient {
  static Future<bool> isValid(
    MqttRtcDescription description, {
    String? username,
    String? password,
  }) async {
    MClient mclient = MClient(mqttRtcDescription: description);
    try {
      MqttClientConnectionStatus? status = await mclient.connect(
        username: username,
        password: password,
      );
      if (status?.state == MqttConnectionState.connected) {
        mclient.disconnect();
        return true;
      }
      return false;
    } catch (exception) {
      return false;
    }
  }
}
