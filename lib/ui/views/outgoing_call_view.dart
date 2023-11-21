import 'package:dieklingel_app/ui/view_models/active_call_view_model.dart';
import 'package:dieklingel_app/ui/view_models/outgoing_call_view_model.dart';
import 'package:dieklingel_app/ui/views/active_call_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt/mqtt.dart';
import 'package:provider/provider.dart';

import '../../components/fade_page_route.dart';
import '../../models/home.dart';

class OutgoingCallView extends StatefulWidget {
  const OutgoingCallView({super.key});

  @override
  State<OutgoingCallView> createState() => _OutgoingCallViewState();
}

class _OutgoingCallViewState extends State<OutgoingCallView> {
  @override
  void initState() {
    super.initState();

    final Home home = context.read<OutgoingCallViewModel>().home;
    final Client connection = context.read<OutgoingCallViewModel>().connection;

    context.read<OutgoingCallViewModel>().onAnswer().then(
      (event) {
        final (call, remoteSessionId) = event;

        Navigator.pushReplacement(
          context,
          FadePageRoute(
            builder: (context) {
              return ChangeNotifierProvider(
                create: (context) => ActiveCallViewModel(
                  home: home,
                  connection: connection,
                  call: call,
                  remoteSessionId: remoteSessionId,
                ),
                child: const ActiveCallView(),
              );
            },
          ),
        );
      },
    );

    context.read<OutgoingCallViewModel>().onHangup().then(
      (_) {
        Navigator.pop(context);
      },
    );

    context.read<OutgoingCallViewModel>().call();
  }

  @override
  Widget build(BuildContext context) {
    final callee = context.select<OutgoingCallViewModel, String>(
      (value) => value.home.name,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.lightBackgroundGray,
      child: SafeArea(
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
                    context.read<OutgoingCallViewModel>().hangup();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
