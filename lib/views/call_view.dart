import 'package:dieklingel_app/views/message_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../messaging/mclient.dart';
import '../models/home.dart';

class CallView extends StatefulWidget {
  final Home home;
  final MClient client;
  const CallView({required this.home, required this.client, super.key});

  @override
  State<StatefulWidget> createState() => _CallView();
}

class _CallView extends State<CallView> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer()..initialize();

  void _onMessagePressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MessageView(),
      ),
    );
  }

  Widget _video(BuildContext context) {
    return RTCVideoView(_renderer);
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
                onPressed: () {},
                child: Text("call"),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.home.name),
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
            _toolbar(context),
          ],
        ),
      ),
    );
  }
}
