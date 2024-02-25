import 'package:flutter/material.dart';
import 'package:flutter_liblinphone/flutter_liblinphone.dart';
import 'package:flutter_liblinphone/widgets.dart';

class ActiveCallView extends StatefulWidget {
  final Core core;
  final Call call;

  const ActiveCallView({super.key, required this.core, required this.call});

  @override
  State<ActiveCallView> createState() => _ActiveCallViewState();
}

class _ActiveCallViewState extends State<ActiveCallView> {
  late final renderer = VideoController(widget.core);
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
      body: Stack(
        children: [
          VideoView(controller: renderer),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.call.terminate();
                    },
                    child: const Text("End Call"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.call.removeCallbacks(cbs);
    renderer.dispose();
    super.dispose();
  }
}
