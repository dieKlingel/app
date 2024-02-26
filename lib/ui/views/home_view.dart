import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:uuid/uuid.dart';

import 'account_view.dart';
import 'call/active_call_view.dart';
import 'call/outgoing_call_view.dart';
import '../extensions/registration_state.dart';
import '../../config/callkeep.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.core});

  final Core core;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Map<String, Call> calls = {};
  late final CoreCbs cbs = Factory.instance.createCoreCbs()
    ..onRegistrationStateChanged = onRegistrationStateChanged
    ..onCallStateChanged = onCallStateChanged;

  RegistrationState registrationState = RegistrationState.none;

  void onRegistrationStateChanged(
    Core core,
    ProxyConfig config,
    RegistrationState state,
  ) {
    setState(() {
      registrationState = state;
    });
  }

  void onCallStateChanged(
    Core core,
    Call call,
    CallState state,
  ) {
    print("state $state");
    switch (state) {
      case CallState.connected:
        /*Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActiveCallView(
              core: widget.core,
              call: call,
            ),
          ),
        );*/
        break;
      case CallState.outgoingInit:
        /*Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OutgoingCallView(
              core: widget.core,
              call: call,
            ),
          ),
        );*/
        break;
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

    CallKeep.instance.onEvent.listen(onCallkeepEvent);
    super.initState();
  }

  void onCallkeepEvent(CallKeepEvent? event) {
    if (event == null) {
      return;
    }
    String uuid = event.data.uuid.toLowerCase();

    switch (event.type) {
      case CallKeepEventType.callStart:
        final params = widget.core.createCallParams()
          ..enableVideo(true)
          ..setVideoDirection(MediaDirection.recvOnly);

        final call = widget.core.inviteWithParams(
          "sip:kai123@sip.linphone.org",
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
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("dieKlingel"),
        leading: registrationState.indicator,
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
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () {}, child: const Text("test")),
            ElevatedButton(
              onPressed: registrationState == RegistrationState.ok
                  ? () {
                      final config = CallKeepOutgoingConfig.fromBaseConfig(
                        config: callKeepBaseConfig,
                        uuid: const Uuid().v4(),
                      );

                      CallKeep.instance.startCall(config);
                    }
                  : null,
              child: const Text("call kai123@sip.linphone.org"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.core.removeCallbacks(cbs);
    super.dispose();
  }
}
