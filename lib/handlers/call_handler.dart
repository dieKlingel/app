import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voip_kit/call.dart';
import 'package:flutter_voip_kit/flutter_voip_kit.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:objectdb/objectdb.dart';

import '../components/notifyable_map.dart';
import '../media/media_ressource.dart';

class CallHandler extends ChangeNotifier {
  static final CallHandler _instance = CallHandler._();
  factory CallHandler.getInstance() => _instance;

  final NotifyableMap<String, MqttRtcClient> _clients =
      NotifyableMap<String, MqttRtcClient>();

  final NotifyableMap<String, MClient> _requested =
      NotifyableMap<String, MClient>();

  List<Call> _calls = [];

  List<Call> get calls => _calls;

  Map<String, MqttRtcClient> get clients => _clients;

  Call? _active;

  Call? get active {
    return _active;
  }

  void _setActive(Call? call) {
    _active = call;
    notifyListeners();
  }

  CallHandler._() {
    _clients.addListener(notifyListeners);

    FlutterVoipKit.callListStream.listen((event) {
      _calls = event;
    });

    FlutterVoipKit.init(
      callStateChangeHandler: callStateChangeHandler,
      callActionHandler: callActionHandler,
    );
  }

  Future<bool> callStateChangeHandler(Call call) async {
    //it is important we perform logic and return true/false for every CallState possible

    switch (call.callState) {
      case CallState.connecting:
        if (!_requested.containsKey(call.uuid)) {
          return false;
        }
        MClient mclient = _requested[call.uuid]!;
        /* if (mclient.isNotConnected()) return false;

        MqttUri description = mclient.uri!.copyWith(
          channel: "${mclient.uri!.channel}rtc/${call.uuid}/",
        );

        MqttRtcClient mqttRtcClient = MqttRtcClient.invite(
          description,
          MediaRessource(),
        );

        _clients[call.uuid] = mqttRtcClient;
        _requested.remove(call.uuid);
        _setActive(call);

        await mqttRtcClient.mediaRessource.open(true, false);

        ObjectDB database = await ObjectDBFactory.named("ice_servers");
        List<Map<dynamic, dynamic>> ice = await database.find({});
        database.close();

        await mqttRtcClient.init(iceServers: {
          "iceServers": ice,
          "sdpSemantics": "unified-plan" // important to work
        }, transceivers: [
          RtcTransceiver(
            kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
            direction: TransceiverDirection.SendRecv,
          ),
          RtcTransceiver(
            kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
            direction: TransceiverDirection.RecvOnly,
          ),
        ]); 

        String? result = await mclient.get(
          "request/rtc/test/",
          description.toString(),
          timeout: const Duration(seconds: 30),
        );

        if (null == result) {
          mqttRtcClient.close();
          return false;
        }
        call.mute(muted: true); */
        return true;
      case CallState.active:
        //here we would likely begin playig audio out of speakers
        if (!_clients.containsKey(call.uuid)) return false;

        MqttRtcClient client = _clients[call.uuid]!;
        await client.open();

        _setActive(call);

        return true;
      case CallState.ended: //end audio, disconnect
        if (!_clients.containsKey(call.uuid)) return false;

        MqttRtcClient client = _clients[call.uuid]!;
        client.close();
        _clients.remove(call.uuid);
        _setActive(null);

        return true;
      case CallState.failed: //cleanup
        if (!_clients.containsKey(call.uuid)) return false;

        MqttRtcClient client = _clients[call.uuid]!;
        client.close();
        _clients.remove(call.uuid);
        _setActive(null);

        return true;
      case CallState.held: //pause audio for specified call
        // TODO: held the call
        return false; // held is not implemented yet, return false, to abort the call.
      default:
        return false;
    }
  }

  Future<bool> callActionHandler(Call call, CallAction action) async {
    //it is important we perform logic and return true/false for every CallState possible
    switch (action) {
      case CallAction.muted:
        //EXAMPLE: here we would perform the logic on our end to mute the audio streams between the caller and reciever
        if (!calls.any((element) => element.uuid == call.uuid)) return false;
        MqttRtcClient client = clients[call.uuid]!;
        client.mediaRessource.stream?.getAudioTracks().first.enabled =
            !call.muted;
        return true;
      default:
        return false;
    }
  }

  void prepare(String uuid, MClient client) {
    _requested[uuid] = client;
  }
}