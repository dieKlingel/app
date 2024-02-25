import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';

import 'active_call_view.dart';

class OutgoingCallView extends StatefulWidget {
  final Core core;
  final Call call;

  const OutgoingCallView({
    super.key,
    required this.core,
    required this.call,
  });

  @override
  State<OutgoingCallView> createState() => _OutgoingCallViewState();
}

class _OutgoingCallViewState extends State<OutgoingCallView> {
  late final cbs = Factory.instance.createCallCbs()
    ..onCallStateChanged = onCallStateChanged;

  @override
  void initState() {
    widget.call.addCallbacks(cbs);
    super.initState();
  }

  void onCallStateChanged(
    Call call,
    CallState state,
  ) {
    switch (state) {
      case CallState.connected:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ActiveCallView(
              core: widget.core,
              call: call,
            ),
          ),
        );
        break;
      case CallState.end:
      case CallState.error:
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("outgoing call view")),
    );
  }

  @override
  void dispose() {
    widget.call.removeCallbacks(cbs);
    super.dispose();
  }
}
