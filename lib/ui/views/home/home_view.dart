import 'dart:convert';
import 'dart:developer';

import 'package:dieklingel_app/ui/views/home/componets/registration_state_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:uuid/uuid.dart';

import '../account_view.dart';
import '../call/active_call_view.dart';
import '../call/outgoing_call_view.dart';
import '../../../config/callkeep.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.core});

  final Core core;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Map<String, Call> calls = {};
  late final CoreCbs cbs = Factory.instance.createCoreCbs()
    ..onRegistrationStateChanged = _onRegistrationStateChanged
    ..onCallStateChanged = _onCallStateChanged
    ..onGlobalStateChanged = _onGlobalStateChanged;

  RegistrationState registrationState = RegistrationState.none;

  void _onGlobalStateChanged(Core core, GlobalState state, String message) {
    log("global core state changed: $state");
  }

  void _onRegistrationStateChanged(
    Core core,
    ProxyConfig config,
    RegistrationState state,
  ) {
    log("Registration state changed: $state.");

    setState(() {
      registrationState = state;
    });
  }

  void _onCallStateChanged(
    Core core,
    Call call,
    CallState state,
  ) {
    log("Call state changed: call: ${call.getCallLog().getCallId()}; state: $state.");
    switch (state) {
      case CallState.incomingReceived:
        final uuid = const Uuid().v4();
        calls[uuid] = call;
        CallKeep.instance.displayIncomingCall(
          CallKeepIncomingConfig.fromBaseConfig(
            config: callKeepBaseConfig,
            uuid: uuid,
            callerName: call.getRemoteAddress().asString(),
            hasVideo: true,
            duration: const Duration(minutes: 2).inMilliseconds.toDouble(),
          ),
        );
        break;
      case CallState.error:
      case CallState.end:
        for (final entry in calls.entries) {
          if (entry.value == call) {
            calls.remove(entry.key);
            CallKeep.instance.endCall(entry.key);
            break;
          }
        }
        break;
      default:
        log("The call state $state for the call ${call.getCallLog().getCallId()} was not handled.");
        break;
    }
  }

  @override
  void initState() {
    widget.core.addCallbacks(cbs);
    final videoActivationPolicy = Factory.instance.createVideoActivationPolicy()
      ..setAutomaticallyInitiate(false)
      ..setAutomaticallyAccept(true);
    widget.core.setVideoActivationPolicy(videoActivationPolicy);

    CallKeep.instance.onEvent.listen(_onCallkeepEvent);
    super.initState();
  }

  void _onCallkeepEvent(CallKeepEvent? event) {
    if (event == null) {
      return;
    }

    String uuid = event.data.uuid.toLowerCase();
    log("Received callkeep event: id: $uuid; type: ${event.type}; data: ${event.data}.");

    switch (event.type) {
      case CallKeepEventType.callIncoming:
        final call = calls[uuid];
        if (call != null) {
          // call was not from pushkit, but linphone, so nothing to do
          break;
        }
        final data = event.data as CallKeepCallData;
        final id = data.extra?["aps"]?["call-id"] as String?;
        if (id == null) {
          break;
        }
        widget.core.pushNotificationReceived(jsonEncode(data.extra), id);
        widget.core.processPushNotification(id);
        print("call incoming via flutter_callkee$id");
        break;
      case CallKeepEventType.callStart:
        final params = widget.core.createCallParams()
          ..enableVideo(true)
          ..setVideoDirection(MediaDirection.recvOnly);

        final call = widget.core.inviteWithParams(
          "kai123",
          params,
        );
        calls[uuid] = call;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OutgoingCallView(
              core: widget.core,
              call: call,
            ),
          ),
        );
        break;
      case CallKeepEventType.callAccept:
        final call = calls[uuid];
        if (call == null) {
          return;
        }
        widget.core.configureAudioSession();
        final params = widget.core.createCallParams(call: call);
        params.enableVideo(true);
        params.enableAudio(true);
        params.setVideoDirection(MediaDirection.recvOnly);
        call.acceptWitParams(params);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActiveCallView(
              core: widget.core,
              call: call,
            ),
          ),
        );
        break;
      case CallKeepEventType.callDecline:
        CallKeep.instance.endCall(uuid);
        final call = calls.remove(uuid);
        if (call == null) {
          return;
        }
        call.terminate();
        break;
      case CallKeepEventType.callEnded:
        final call = calls.remove(uuid);
        if (call == null) {
          return;
        }
        call.terminate();
        break;
      case CallKeepEventType.muteToggled:
        final data = event.data as MuteToggleData;
        final call = calls[uuid];
        if (call == null) {
          return;
        }
        call.setMicrophoneMuted(data.isMuted);
        break;
      case CallKeepEventType.audioSessionToggled:
        final data = event.data as AudioSessionToggleData;
        widget.core.activateAudioSession(data.isActivated);
        break;
      case CallKeepEventType.devicePushTokenUpdated:
        final data = event.data as VoipTokenData;
        final token = data.token;
        if (token.isNotEmpty) {
          widget.core.getPushNotificationConfig().setVoipToken(token);
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("dieKlingel"),
        leading: IconButton(
          onPressed: () {
            widget.core.refreshRegisters();
          },
          icon: RegistrationStateIcon(state: registrationState),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AccountView(core: widget.core),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: const Center(child: Text("dieKlingel")),
    );
  }

  @override
  void dispose() {
    widget.core.removeCallbacks(cbs);
    super.dispose();
  }
}
