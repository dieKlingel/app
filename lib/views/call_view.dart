import 'package:dieklingel_app/messaging/mclient_state.dart';
import 'package:dieklingel_app/view_models/call_view_model.dart';
import 'package:dieklingel_app/views/message_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

import '../messaging/mclient.dart';
import '../models/home.dart';

class CallView extends StatefulWidget {
  final CallViewModel vm;

  const CallView({
    required this.vm,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CallView();
}

class _CallView extends State<CallView> {
  void _onMessagePressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MessageView(),
      ),
    );
  }

  Widget _video(BuildContext context) {
    RTCVideoRenderer? renderer =
        context.watch<CallViewModel>().client?.rtcVideoRenderer;
    if (renderer == null) {
      return Text("no video");
    }
    return InteractiveViewer(
      child: RTCVideoView(renderer),
    );
  }

  Widget _toolbar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                onPressed: context.watch<CallViewModel>().isConnected
                    ? () => context.read<CallViewModel>().hangup()
                    : () => context.read<CallViewModel>().call(),
                child: Text(
                  context.watch<CallViewModel>().isConnected
                      ? "hangup"
                      : "call",
                ),
              ),
              CupertinoButton(
                onPressed: () {},
                child: Text("mic"),
              ),
              CupertinoButton(
                onPressed: () {},
                child: Text("speaker"),
              ),
              CupertinoButton(
                onPressed: () {},
                child: Text("lock"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _taskbar(BuildContext context) {
    return Row(
      children: [
        ChangeNotifierProvider.value(
          value: context.read<CallViewModel>().mclient,
          builder: (context, child) {
            return Icon(
              (context.watch<MClient>().state == MClientState.connected)
                  ? CupertinoIcons.check_mark_circled
                  : CupertinoIcons.clear_circled,
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.vm,
      builder: (context, child) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(context.watch<CallViewModel>().home.name),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _onMessagePressed(context),
            child: const Icon(
              CupertinoIcons.pencil_ellipsis_rectangle,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _video(context),
              _taskbar(context),
              _toolbar(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.vm.hangup();
    super.dispose();
  }
}
