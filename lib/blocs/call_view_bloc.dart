import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/request.dart';
import 'package:dieklingel_app/models/response.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/utils/speaker_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../utils/rtc_client_wrapper.dart';
import '../utils/rtc_transceiver.dart';

class CallViewBloc extends Bloc<CallEvent, CallState> {
  final HomeRepository homeRepository;
  final IceServerRepository iceServerRepository;
  RtcClientWrapper? rtcclient;
  CancelableOperation? _requestOperation;
  MqttClient? client;
  Subscription? candidateSub;

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

    final MqttClient client = MqttClient(home.uri);
    await client.connect(
      username: home.username ?? "",
      password: home.password ?? "",
    );

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

    candidateSub?.cancel();
    candidateSub = client.subscribe(
      path.normalize("./$uuid/connection/candidate"),
      (topic, message) {
        Map<String, dynamic> candidate = jsonDecode(
          Request.fromMap(
            jsonDecode(message),
          ).body,
        );

        rtcclient?.addIceCandidate(
          RTCIceCandidate(
            candidate["candidate"],
            candidate["sdpMid"],
            candidate["sdpMLineIndex"] as int,
          ),
        );
      },
    );

    rtcclient!.onIceCandidate((RTCIceCandidate candidate) {
      client.publish(
        path.normalize("./${home.uri.path}/rtc/connections/candidate/$uuid"),
        Request.withJsonBody("GET", candidate.toMap()).toJsonString(),
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

    String answerChannel = const Uuid().v4();
    final operation = CancelableOperation.fromFuture(
      client.once(
        path.normalize(
          "./${home.uri.path}/rtc/connections/create/$uuid/$answerChannel",
        ),
        timeout: const Duration(seconds: 15),
      ),
    );
    client.publish(
      path.normalize("./${home.uri.path}/rtc/connections/create/$uuid"),
      Request.withJsonBody(
        "GET",
        (await rtcclient!.offer()).toMap(),
      ).withAnswerChannel(answerChannel).toJsonString(),
    );
    _requestOperation = operation;

    await operation.value.then((value) async {
      Response response = Response.fromMap(jsonDecode(value));
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

      if (state is! CallInitatedState) {
        add(CallHangup());
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
        "could not connect to the given doorunit",
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

    client?.publish(
      path.normalize("./${home.uri.path}/rtc/connections/close/$uuid"),
      jsonEncode(
        Request("GET", ""),
      ),
    );
    candidateSub?.cancel();
    candidateSub = null;
    client?.disconnect();
    client = null;
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
    candidateSub?.cancel();
    client?.disconnect();
    client = null;
    await rtcclient?.dispose();
    return super.close();
  }
}
