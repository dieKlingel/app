import 'package:dieklingel_app/views/message_view.dart';
import 'package:flutter/cupertino.dart';

import '../models/home.dart';

class CallView extends StatefulWidget {
  final Home home;
  const CallView({required this.home, super.key});

  @override
  State<StatefulWidget> createState() => _CallView();
}

class _CallView extends State<CallView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("state");
  }

  void _onMessagePressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MessageView(),
      ),
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
      child: Text("a"),
    );
  }
}
