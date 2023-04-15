import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/utils/microphone_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:dieklingel_core_shared/blocs/mqtt_client_bloc.dart';
import 'package:dieklingel_core_shared/models/mqtt_uri.dart';
import 'package:dieklingel_core_shared/mqtt/mqtt_client_state.dart';
import 'package:dieklingel_core_shared/mqtt/mqtt_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

import '../signaling/signaling_message.dart';
import '../signaling/signaling_message_type.dart';
import '../utils/mqtt_channel.dart';
import '../utils/rtc_client_wrapper.dart';
import '../utils/rtc_transceiver.dart';

class CallViewBloc extends Bloc<CallEvent, CallState> {
  final HomeRepository homeRepository;
  final IceServerRepository iceServerRepository;
  MqttClientBloc? mqtt;
  RtcClientWrapper? rtcclient;

  SpeakerState _speakerState = SpeakerState.muted;
  MicrophoneState _microphoneState = MicrophoneState.muted;

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
    await mqtt?.disconnect();
    mqtt = MqttClientBloc();
    mqtt?.uri.add(home.uri);
    MqttClientState? state = await mqtt?.state
        .firstWhere((element) => element == MqttClientState.connected)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => MqttClientState.disconnected,
        );
    if (state != MqttClientState.connected) {
      emit(CallEndedState());
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
    MqttChannel channel = MqttChannel("rtc/$uuid");
    String invite = channel.append("invite").toString();
    String answer = channel.append("answer").toString();

    StreamSubscription? subscription = mqtt?.watch(answer).listen(
      (event) {
        SignalingMessage message = SignalingMessage.fromJson(
          jsonDecode(event.value),
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

        mqtt?.message.add(
          ChannelMessage(
            invite,
            jsonEncode(message.toJson()),
          ),
        );
      },
    );

    await rtcclient?.ressource.open(true, false);
    if (mqtt == null) {
      rtcclient?.ressource.close();
      return;
    }
    MqttChannel rtcChannel = MqttChannel(
      home.uri.channel,
    ).append(channel.toString());

    MqttUri rtcUri = home.uri.copyWith(channel: rtcChannel.toString());

    MqttResponse? result = await mqtt?.request(
      "request/rtc/connect/${const Uuid().v4()}",
      jsonEncode(rtcUri.toMap()),
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

    _speakerState = SpeakerState.speaker;
    _microphoneState = MicrophoneState.muted;
    rtcclient?.ressource.stream?.getAudioTracks().forEach((track) {
      Helper.setMicrophoneMute(true, track);
    });

    emit(
      CallActiveState(
        microphoneState: _microphoneState,
        speakerState: _speakerState,
        renderer: renderer,
      ),
    );
  }

  Future<void> _onHangup(CallHangup event, Emitter<CallState> emit) async {
    _speakerState = SpeakerState.muted;
    _microphoneState = MicrophoneState.muted;
    await rtcclient?.close();
    rtcclient = null;
    emit(CallEndedState());
  }

  Future<void> _onToogleMicrophone(
    CallToogleMicrophone event,
    Emitter<CallState> emit,
  ) async {
    _microphoneState = _microphoneState.next();

    switch (_microphoneState) {
      case MicrophoneState.muted:
        rtcclient?.ressource.stream?.getAudioTracks().forEach((track) {
          Helper.setMicrophoneMute(true, track);
        });
        break;
      case MicrophoneState.unmuted:
        rtcclient?.ressource.stream?.getAudioTracks().forEach((track) {
          Helper.setMicrophoneMute(false, track);
        });
        break;
    }

    RTCVideoRenderer? renderer = rtcclient?.renderer;
    if (renderer == null) {
      emit(CallEndedState());
      return;
    }

    emit(
      CallActiveState(
        microphoneState: _microphoneState,
        speakerState: _speakerState,
        renderer: renderer,
      ),
    );
  }

  Future<void> _onToogleSpeaker(
      CallToogleSpeaker event, Emitter<CallState> emit) async {
    _speakerState = _speakerState.next(
      skip: [if (kIsWeb) SpeakerState.headphone],
    );

    switch (_speakerState) {
      case SpeakerState.muted:
        rtcclient?.renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = false;
        });
        break;
      case SpeakerState.headphone:
        rtcclient?.renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(true);
          }
        });
        break;
      case SpeakerState.speaker:
        rtcclient?.renderer.srcObject?.getAudioTracks().forEach((track) {
          track.enabled = true;
          if (!kIsWeb) {
            track.enableSpeakerphone(false);
          }
        });
        break;
    }

    RTCVideoRenderer? renderer = rtcclient?.renderer;
    if (renderer == null) {
      emit(CallEndedState());
      return;
    }

    emit(
      CallActiveState(
        microphoneState: _microphoneState,
        speakerState: _speakerState,
        renderer: renderer,
      ),
    );
  }

  @override
  Future<void> close() async {
    await rtcclient?.close();
    await mqtt?.disconnect();
    return super.close();
  }
}
