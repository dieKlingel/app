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
  String callee = "";

  @override
  void initState() {
    widget.call.addCallbacks(cbs);
    setState(() {
      callee = widget.call.getRemoteAddress().asString();
    });
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

  void _onHangup() {
    widget.call.terminate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              const Text("Outgoing call to"),
              Text(
                callee,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(flex: 5),
              IconButton.filled(
                iconSize: 26,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.call_end),
                ),
                onPressed: _onHangup,
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.call.removeCallbacks(cbs);
    super.dispose();
  }
}
