import 'dart:async';
import 'dart:convert';

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
import 'package:http/http.dart' as http;
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../utils/rtc_client_wrapper.dart';
import '../utils/rtc_transceiver.dart';

class CallViewBloc extends Bloc<CallEvent, CallState> {
  final HomeRepository homeRepository;
  final IceServerRepository iceServerRepository;
  RtcClientWrapper? rtcclient;

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
      iceServers: iceServerRepository.servers,
      transceivers: [
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          direction: TransceiverDirection.SendRecv,
        ),
        RtcTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          direction: TransceiverDirection.RecvOnly,
        )
      ],
    );

    Router router = Router();
    router.connect("/connection", (Request request) async {
      String body = await request.readAsString();
      SignalingMessage message = SignalingMessage.fromJson(
        jsonDecode(body),
      );
      // rtcclient could be null, if the connection as already closed on this side
      rtcclient?.addMessage(message);

      return Response.ok("Ok");
    });

    MqttHttpServer server = MqttHttpServer();
    await server.serve(
      router,
      home.uri.toUri().replace(fragment: "", path: uuid),
      powerdBy: "com.dieklingel.app.$uuid",
    );

    rtcclient?.onMessage(
      (SignalingMessage message) {
        if (message.type == SignalingMessageType.leave ||
            message.type == SignalingMessageType.error) {
          rtcclient?.dispose();
        }

        MqttHttpClient().socket(
          home.uri.toUri().append(path: "/rtc/connections/$uuid"),
          body: jsonEncode(message.toJson()),
        );
      },
    );

    await rtcclient?.ressource.open(true, false);

    if (rtcclient == null) {
      return;
    }

    http.Response response;
    try {
      response = await MqttHttpClient().post(
        home.uri
            .toUri()
            .append(path: "/rtc/connections/$uuid")
            .replace(fragment: ""),
      );
      if (response.statusCode != 201) {
        add(CallHangup());
        return;
      }
    } on TimeoutException catch (exception) {
      emit(
        CallCancelState(
          "Could not connect to the given Server! ${exception.message}",
        ),
      );
      add(CallHangup());
      return;
    }

    await rtcclient?.open();
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
  }

  Future<void> _onHangup(CallHangup event, Emitter<CallState> emit) async {
    await rtcclient?.close();
    rtcclient = null;
    emit(CallEndedState());
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
    await rtcclient?.close();
    return super.close();
  }
}
