import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/models/mqtt_uri.dart';
import 'package:uuid/uuid.dart';

import 'package:mqtt/mqtt.dart' as mqtt;

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../utils/rtc_client_wrapper.dart';
import '../utils/rtc_transceiver.dart';

class CallViewBloc extends Bloc<CallEvent, CallState> {
  final HomeRepository homeRepository;
  final IceServerRepository iceServerRepository;
  mqtt.Client? mqttclient;
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
    await mqttclient?.disconnect();
    mqttclient = mqtt.Client();

    try {
      await mqttclient?.connect(
        home.uri,
        username: home.username,
        password: home.password,
      );
    } catch (e) {
      emit(CallCancelState("Could not connect to the given Server!"));
      add(CallHangup());
      return;
    }

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

    String uuid = const Uuid().v4();
    MqttUri channel = MqttUri(channel: "rtc/$uuid");
    String invite = MqttUri(channel: "rtc/$uuid/invite").channel;
    String answer = MqttUri(channel: "rtc/$uuid/answer").channel;

    StreamSubscription? subscription = mqttclient?.watch(answer).listen(
      (event) {
        SignalingMessage message = SignalingMessage.fromJson(
          jsonDecode(event.payload),
        );

        rtcclient?.addMessage(message);
      },
    );

    rtcclient?.onMessage(
      (SignalingMessage message) {
        if (message.type == SignalingMessageType.leave ||
            message.type == SignalingMessageType.error) {
          subscription?.cancel();
          rtcclient?.dispose();
        }

        mqttclient?.publish(
          mqtt.Message(
            invite,
            jsonEncode(message.toJson()),
          ),
        );
      },
    );

    await rtcclient?.ressource.open(true, false);
    if (mqttclient == null) {
      rtcclient?.ressource.close();
      return;
    }

    MqttUri rtcUri = home.uri.copyWith(channel: channel.channel);

    mqtt.Response? result = await mqttclient?.request(
      mqtt.Message(
        "request/rtc/connect/${const Uuid().v4()}",
        jsonEncode(rtcUri.toMap()),
      ),
    );

    if (result?.status != 200) {
      rtcclient?.close();
      emit(CallEndedState());
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
    await mqttclient?.disconnect();
    return super.close();
  }
}
