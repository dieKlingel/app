import 'dart:convert';

import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import 'media_ressource.dart';
import 'rtc_transceiver.dart';

class RtcClientWrapper {
  final MediaRessource ressource = MediaRessource();
  final RTCVideoRenderer renderer = RTCVideoRenderer();
  final List<IceServer> servers;
  final List<RtcTransceiver> transceivers;
  late final RTCPeerConnection connection;
  bool _isDisposed = false;

  void Function(SignalingMessage)? _onMessage;

  RtcClientWrapper._(this.servers, this.transceivers);

  static Future<RtcClientWrapper> create({
    List<IceServer> iceServers = const [],
    List<RtcTransceiver> transceivers = const [],
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    RtcClientWrapper wrapper = RtcClientWrapper._(iceServers, transceivers);
    await wrapper.renderer.initialize();

    List<Map<String, dynamic>> servers = iceServers
        .map(
          (e) => {
            "urls": e.urls,
            "username": e.username,
            "credential": e.credential
          },
        )
        .toList();

    Map<String, dynamic> configuration = {};
    configuration["iceServers"] = servers;
    configuration["sdpSemantics"] = "unified-plan";
    wrapper.connection = await createPeerConnection(configuration);

    wrapper.connection
      ..onIceCandidate = wrapper._onIceCandidate
      ..onConnectionState = wrapper._onConnectionState
      ..onTrack = wrapper._onTrack;

    for (RtcTransceiver transceiver in transceivers) {
      await wrapper.connection.addTransceiver(
        kind: transceiver.kind,
        init: RTCRtpTransceiverInit(direction: transceiver.direction),
      );
    }

    return wrapper;
  }

  void addMessage(SignalingMessage message) async {
    switch (message.type) {
      case SignalingMessageType.offer:
        MediaStream? stream = ressource.stream;
        if (null != stream) {
          for (MediaStreamTrack track in stream.getTracks()) {
            connection.addTrack(track, stream);
          }
        }

        final remote = RTCSessionDescription(
          message.data["sdp"],
          message.data["type"],
        );

        await connection.setRemoteDescription(remote);
        final local = await connection.createAnswer();
        await connection.setLocalDescription(local);

        SignalingMessage answer = SignalingMessage()
          ..type = SignalingMessageType.answer
          ..data = local.toMap();

        _onMessage?.call(answer);
        break;
      case SignalingMessageType.answer:
        final description = RTCSessionDescription(
          message.data["sdp"],
          message.data["type"],
        );

        await connection.setRemoteDescription(description);
        break;
      case SignalingMessageType.candidate:
        final candidate = RTCIceCandidate(
          message.data["candidate"],
          message.data["sdpMid"],
          message.data["sdpMLineIndex"],
        );

        await connection.addCandidate(candidate);
        break;
      case SignalingMessageType.leave:
      case SignalingMessageType.busy:
      case SignalingMessageType.error:
        close();
        break;
    }
  }

  void onMessage(void Function(SignalingMessage) handler) {
    _onMessage = handler;
  }

  Future<void> open() async {
    RTCSessionDescription offer = await connection.createOffer();
    await connection.setLocalDescription(offer);

    SignalingMessage message = SignalingMessage();
    message.type = SignalingMessageType.offer;
    message.data = offer.toMap();

    _onMessage?.call(message);
  }

  Future<void> close() async {
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.leave;

    await dispose();
    _onMessage?.call(message);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    ressource.close();
    await connection.close();
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    SignalingMessage message = SignalingMessage()
      ..type = SignalingMessageType.candidate
      ..data = candidate.toMap();

    _onMessage?.call(message);
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        close();
        break;
      default:
        break;
    }
  }

  void _onTrack(RTCTrackEvent event) {
    if (event.streams.isEmpty) {
      return;
    }

    renderer.srcObject = event.streams.first;
  }
}
