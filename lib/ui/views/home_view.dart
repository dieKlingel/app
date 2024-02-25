import 'package:dieklingel_app/ui/extensions/registration_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

import 'account_view.dart';
import 'call/outgoing_call_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.core});

  final Core core;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
    print("call state changed: $state");
  }

  @override
  void initState() {
    widget.core.addCallbacks(cbs);
    final videoActivationPolicy =
        Factory.instance.createVideoActivationPolicy();
    videoActivationPolicy.setAutomaticallyInitiate(false);
    videoActivationPolicy.setAutomaticallyAccept(false);
    widget.core.setVideoActivationPolicy(videoActivationPolicy);
    super.initState();
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
            ElevatedButton(
                onPressed: () {
                  widget.core.reloadSoundDevices();
                  final devices = widget.core.getAudioDevices();
                  devices.forEach((element) {
                    print(element.getDeviceName());
                  });
                },
                child: Text("test")),
            ElevatedButton(
              onPressed: registrationState == RegistrationState.ok
                  ? () {
                      final params = widget.core.createCallParams();
                      params.enableVideo(true);
                      params.setVideoDirection(MediaDirection.recvOnly);

                      final call = widget.core.inviteWithParams(
                        "sip:kai123@sip.linphone.org",
                        params,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OutgoingCallView(
                            core: widget.core,
                            call: call,
                          ),
                        ),
                      );
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
