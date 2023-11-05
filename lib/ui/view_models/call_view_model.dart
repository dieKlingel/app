import 'dart:convert';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/messages/answer_message.dart';
import 'package:dieklingel_app/models/messages/candidate_message.dart';
import 'package:dieklingel_app/models/messages/candidate_message_body.dart';
import 'package:dieklingel_app/models/messages/close_message.dart';
import 'package:dieklingel_app/models/messages/message_header.dart';
import 'package:dieklingel_app/models/messages/offer_message.dart';
import 'package:dieklingel_app/models/messages/session_message_body.dart';
import 'package:dieklingel_app/models/messages/session_message_header.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/utils/rtc_client_wrapper.dart';
import 'package:dieklingel_app/utils/rtc_transceiver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class CallViewModel extends ChangeNotifier {
  final HiveHome home;
  final MqttClient client;
  final IceServerRepository iceServerRepository;

  RtcClientWrapper? _call;
  String _remoteSessionId = "";
  String _localSessionId = "";

  CallViewModel(this.home, this.client, this.iceServerRepository) {
    client.subscribe(
      "${home.username}/connections/answer",
      (topic, message) async {
        final call = _call;
        if (call == null) {
          return;
        }

        try {
          final payload = AnswerMessage.fromMap(json.decode(message));
          _remoteSessionId = payload.header.senderSessionId;
          await call.setRemoteDescription(payload.body.sessionDescription);
        } catch (e) {
          print(e);
        }
      },
    );

    client.subscribe(
      "${home.username}/connections/candidate",
      (topic, message) {
        final call = _call;
        if (call == null) {
          return;
        }

        try {
          final payload = CandidateMessage.fromMap(json.decode(message));
          call.addIceCandidate(payload.body.iceCandidate);
        } catch (e) {
          print(e);
        }
      },
    );

    client.subscribe(
      "${home.username}/connections/close",
      (topic, message) async {
        final call = _call;
        if (call == null) {
          return;
        }

        try {
          CloseMessage.fromMap(json.decode(message));
          await call.dispose();
          _call = null;
        } catch (e) {
          print(e);
        }
      },
    );
  }

  bool get isInCall {
    return _call != null;
  }

  bool get isConnecting {
    final call = _call;
    if (call == null) {
      return false;
    }
    return call.state.value !=
        RTCPeerConnectionState.RTCPeerConnectionStateConnected;
  }

  RTCVideoRenderer? get renderer {
    return _call?.renderer;
  }

  void dial() async {
    _localSessionId = const Uuid().v4();
    final call = await RtcClientWrapper.create(
      uuid: _localSessionId,
      iceServers: iceServerRepository.servers,
      transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.RecvOnly,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
      ],
    );
    call.state.addListener(() {
      print(call.state.value);
      notifyListeners();
    });
    _call = call;
    notifyListeners();

    final offer = await call.offer();
    final payload = OfferMessage(
      header: MessageHeader(
        senderDeviceId: home.username ?? "",
        sessionId: call.uuid,
      ),
      body: SessionMessageBody(
        sessionDescription: offer,
      ),
    );

    client.publish(
      normalize("./${home.uri.path}/connections/offer"),
      json.encode(payload.toMap()),
    );

    call.onIceCandidate((p0) {
      final payload = CandidateMessage(
        header: SessionMessageHeader(
          senderDeviceId: home.username ?? "",
          senderSessionId: _localSessionId,
          sessionId: _remoteSessionId,
        ),
        body: CandidateMessageBody(
          iceCandidate: p0,
        ),
      );

      client.publish(
        normalize("./${home.uri.path}/connections/candidate"),
        json.encode(payload.toMap()),
      );
    });
  }

  void hangup() async {
    final call = _call;
    if (call == null) {
      return;
    }
    final payload = CloseMessage(
      header: SessionMessageHeader(
        senderDeviceId: home.username ?? "",
        senderSessionId: call.uuid,
        sessionId: _remoteSessionId,
      ),
    );

    await call.dispose();
    _call = null;
    notifyListeners();

    client.publish(
      normalize("./${home.uri.path}/connections/close"),
      json.encode(payload.toMap()),
    );
  }
}
