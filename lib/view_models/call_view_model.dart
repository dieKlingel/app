import 'dart:convert';
import 'package:dieklingel_app/media/media_ressource.dart';
import 'package:dieklingel_app/media/media_ressource_impl.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:dieklingel_app/models/ice_server.dart';
import 'package:dieklingel_app/models/mqtt_uri.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_app/rtc/rtc_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../models/home.dart';
import '../rtc/rtc_transceiver.dart';

class CallViewModel extends ChangeNotifier {
  final Home home;
  final MClient mclient;
  MqttRtcClient? client;

  CallViewModel({
    required this.home,
    required this.mclient,
  }) {
    mclient.addListener(notifyListeners);
  }

  bool get isConnected {
    if (client == null) {
      return false;
    }
    if (_callRequested) {
      return true;
    }
    if (client?.rtcConnectionState == RtcConnectionState.disconnected) {
      return false;
    }
    return true;
  }

  bool get isCallRequested {
    return _callRequested;
  }

  bool _callRequested = false;

  bool get isMuted {
    return client?.mediaRessource.stream
            ?.getAudioTracks()
            .any((element) => element.muted ?? false) ??
        false;
  }

  Future<void> call() async {
    await hangup();

    MqttUri? uri = mclient.uri;
    if (uri == null) {
      return;
    }

    String uuid = const Uuid().v4();
    uri = uri.copyWith(channel: "${uri.channel}rtc/$uuid/");

    client = MqttRtcClient.invite(uri, MediaRessourceImpl());
    client?.addListener(notifyListeners);

    _callRequested = true;
    notifyListeners();

    await client?.mediaRessource.open(true, false);

    await client?.init(
      iceServers: IceServer.boxx.values.toList(),
      transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.RecvOnly,
        ),
      ],
    );

    String? result = await mclient.get(
      "request/rtc/test/",
      jsonEncode(uri.toMap()),
      timeout: const Duration(seconds: 30),
    );

    if (result == null) {
      await hangup();
      return;
    }

    await client?.open();

    _callRequested = false;
    notifyListeners();
  }

  Future<void> hangup() async {
    client?.close();
    notifyListeners();
    if (client == null) {
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    client = null;
  }

  void mute() {
    client?.mediaRessource.stream?.getAudioTracks().forEach((element) {
      element.enabled = false;
    });
    notifyListeners();
  }

  void unmute() {
    client?.mediaRessource.stream?.getAudioTracks().forEach((element) {
      element.enabled = true;
    });
    notifyListeners();
  }
}
