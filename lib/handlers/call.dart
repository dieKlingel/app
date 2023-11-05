import 'dart:async';

import '../models/ice_server.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Call extends ChangeNotifier {
  final String id;
  final List<IceServer> iceServers;
  final RTCVideoRenderer renderer = RTCVideoRenderer();
  final StreamController<RTCIceCandidate> _localIceCandidates =
      StreamController();
  final StreamController<RTCIceCandidate> _remoteIceCandidates =
      StreamController();

  RTCPeerConnection? connection;

  Call(
    this.id,
    this.iceServers,
  ) {
    WidgetsFlutterBinding.ensureInitialized();
    _remoteIceCandidates.stream.listen((event) {
      connection!.addCandidate(event);
    });
  }

  Future<RTCSessionDescription> offer() async {
    await renderer.initialize();

    connection = await createPeerConnection({
      "iceServers": iceServers.map((e) => e.toMap()).toList(),
      "sdpSemantics": "unified-plan",
    });

    connection!
      ..onIceCandidate = (candidate) {
        _localIceCandidates.add(candidate);
      }
      ..onTrack = (event) {
        if (event.streams.isEmpty) {
          return;
        }

        renderer.srcObject = event.streams.first;
      }
      ..onConnectionState = (state) {
        notifyListeners();
      };

    await connection!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    );
    await connection!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    final offer = await connection!.createOffer();
    await connection!.setLocalDescription(offer);
    return offer;
  }

  Future<void> withRemoteAnswer(RTCSessionDescription answer) async {
    await connection!.setRemoteDescription(answer);
  }

  RTCPeerConnectionState get state {
    final connectionState = connection?.connectionState;
    if (connectionState == null) {
      return RTCPeerConnectionState.RTCPeerConnectionStateClosed;
    }

    return connectionState;
  }

  Stream<RTCIceCandidate> get localIceCandidates {
    return _localIceCandidates.stream;
  }

  Sink<RTCIceCandidate> get remoteIceCandidates {
    return _remoteIceCandidates.sink;
  }

  Future<void> close() async {
    _localIceCandidates.close();
    _remoteIceCandidates.close();
    renderer.dispose();
  }
}
