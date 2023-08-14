import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:dieklingel_app/extensions/uri.dart';
import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../utils/rtc_client_wrapper.dart';
import '../utils/rtc_transceiver.dart';

class CallViewBloc extends Bloc<CallEvent, CallState> {
  final HomeRepository homeRepository;
  final IceServerRepository iceServerRepository;
  RtcClientWrapper? rtcclient;
  CancelableOperation? _requestOperation;

  CallViewBloc(
    this.homeRepository,
    this.iceServerRepository,
  ) : super(CallState()) {
    on<CallStart>(_onStart);
    on<CallHangup>(_onHangup);
    on<CallToogleMicrophone>(_onToogleMicrophone);
    on<CallToogleSpeaker>(_onToogleSpeaker);
  }

  HiveHome get home {
    HiveHome? home = homeRepository.selected;
    if (home == null) {
      throw Exception(
        "cannot read the selected home. Please select a Home in HomeRepository first",
      );
    }
    return home;
  }

  Future<void> _onStart(CallStart event, Emitter<CallState> emit) async {
    emit(CallInitatedState());

    String uuid = const Uuid().v4();

    // create rtc connection
    rtcclient = await RtcClientWrapper.create(
      uuid: uuid,
      iceServers: iceServerRepository.servers,
      transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.SendRecv,
        )
      ],
    );

    Router router = Router();
    router.connect("/connection/candidate", (Request request) async {
      String body = await request.readAsString();
      Map<String, dynamic> json = jsonDecode(body);

      // rtcclient could be null, if the connection as already closed on this side
      rtcclient!.addIceCandidate(RTCIceCandidate(
        json["candidate"],
        json["sdpMid"],
        json["sdpMLineIndex"] as int,
      ));

      return Response.ok("Ok");
    });

    MqttHttpServer server = MqttHttpServer();
    Uri uri = home.uri.replace(fragment: "", path: uuid);

    await server.serve(
      router,
      uri,
      powerdBy: "com.dieklingel.app.$uuid",
    );

    rtcclient!.onIceCandidate((RTCIceCandidate candidate) {
      MqttHttpClient().socket(
        home.uri.append(path: "/rtc/connections/candidate/$uuid"),
        body: jsonEncode(candidate.toMap()),
      );
    });

    await rtcclient!.ressource.open(true, false);
    MediaStream? stream = rtcclient!.ressource.stream;
    if (null != stream) {
      for (MediaStreamTrack track in stream.getTracks()) {
        rtcclient!.connection.addTrack(track, stream);
        // Helper.setMicrophoneMute(true, track);
      }
    }

    if (rtcclient == null) {
      return;
    }

    await _requestOperation?.cancel();

    final operation = CancelableOperation.fromFuture(
      MqttHttpClient().post(
        home.uri
            .append(path: "/rtc/connections/create/$uuid")
            .replace(fragment: ""),
        body: jsonEncode((await rtcclient!.offer()).toMap()),
      ),
    );
    _requestOperation = operation;
    await operation.value.then((response) async {
      if (response.statusCode != 201) {
        add(CallHangup());
      }

      final Map<String, dynamic> answer = jsonDecode(response.body);
      final description = RTCSessionDescription(
        answer["sdp"],
        answer["type"],
      );
      await rtcclient!.setRemoteDescription(description);

      RTCVideoRenderer? renderer = rtcclient?.renderer;
      if (renderer == null) {
        return;
      }

      emit(
        CallActiveState(
          microphoneState: rtcclient!.microphoneState,
          speakerState: rtcclient!.speakerState,
          renderer: renderer,
        ),
      );
    }).onError<TimeoutException>((exception, stackTrace) async {
      emit(CallCancelState(
        "Could not connect to the given Server! ${exception.message}",
      ));
      rtcclient?.ressource.close();
      await rtcclient?.dispose();
      rtcclient = null;
    });
  }

  Future<void> _onHangup(CallHangup event, Emitter<CallState> emit) async {
    String? uuid = rtcclient?.uuid;
    _requestOperation?.cancel();

    emit(CallEndedState());
    rtcclient?.ressource.close();
    await rtcclient?.dispose();
    rtcclient = null;

    try {
      await MqttHttpClient().post(
        home.uri
            .append(path: "/rtc/connections/close/$uuid")
            .replace(fragment: ""),
      );
    } on TimeoutException catch (_) {}
  }

  Future<void> _onToogleMicrophone(
    CallToogleMicrophone event,
    Emitter<CallState> emit,
  ) async {
    if (rtcclient == null) {
      return;
    }

    rtcclient!.microphoneState = rtcclient!.microphoneState.next();

    RTCVideoRenderer? renderer = rtcclient?.renderer;
    if (renderer == null) {
      emit(CallEndedState());
      return;
    }

    emit(
      CallActiveState(
        microphoneState: rtcclient!.microphoneState,
        speakerState: rtcclient!.speakerState,
        renderer: renderer,
      ),
    );
  }

  Future<void> _onToogleSpeaker(
    CallToogleSpeaker event,
    Emitter<CallState> emit,
  ) async {
    if (rtcclient == null) {
      return;
    }

    rtcclient!.speakerState = rtcclient!.speakerState.next(
      skip: [if (kIsWeb) SpeakerState.headphone],
    );

    RTCVideoRenderer? renderer = rtcclient?.renderer;
    if (renderer == null) {
      emit(CallEndedState());
      return;
    }

    emit(
      CallActiveState(
        microphoneState: rtcclient!.microphoneState,
        speakerState: rtcclient!.speakerState,
        renderer: renderer,
      ),
    );
  }

  @override
  Future<void> close() async {
    await rtcclient?.dispose();
    return super.close();
  }
}
