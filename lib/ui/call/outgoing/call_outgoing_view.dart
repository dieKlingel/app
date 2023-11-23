import 'dart:ui';

import 'package:dieklingel_app/ui/call/active/call_active_view_model.dart';
import 'package:dieklingel_app/ui/call/outgoing/call_outgoing_view_model.dart';
import 'package:dieklingel_app/ui/call/active/call_active_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt/mqtt.dart';
import 'package:provider/provider.dart';

import '../../../components/fade_page_route.dart';
import '../../../models/home.dart';

class CallOutgoingView extends StatefulWidget {
  const CallOutgoingView({super.key});

  @override
  State<CallOutgoingView> createState() => _CallOutgoingViewState();
}

class _CallOutgoingViewState extends State<CallOutgoingView> {
  @override
  void initState() {
    super.initState();

    final Home home = context.read<CallOutgoingViewModel>().home;
    final Client connection = context.read<CallOutgoingViewModel>().connection;

    context.read<CallOutgoingViewModel>().onAnswer().then(
      (event) {
        final (call, remoteSessionId) = event;

        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) {
              return ChangeNotifierProvider(
                create: (context) => CallActiveViewModel(
                  home: home,
                  connection: connection,
                  call: call,
                  remoteSessionId: remoteSessionId,
                ),
                child: const CallActiveView(),
              );
            },
          ),
        );
      },
    );

    context.read<CallOutgoingViewModel>().onHangup().then(
      (_) {
        Navigator.pop(context);
      },
    );

    context.read<CallOutgoingViewModel>().call();
  }

  @override
  Widget build(BuildContext context) {
    final callee = context.select<CallOutgoingViewModel, String>(
      (value) => value.home.name,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.lightBackgroundGray,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Image.asset(
                "assets/images/house.png",
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        callee,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        "outgoing call...",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Hero(
                    tag: "call_hangup_button",
                    child: CupertinoButton(
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      minSize: kMinInteractiveDimensionCupertino * 1.2,
                      borderRadius: BorderRadius.circular(999),
                      child: const Icon(
                        CupertinoIcons.xmark,
                      ),
                      onPressed: () {
                        context.read<CallOutgoingViewModel>().hangup();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
