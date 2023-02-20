/* import 'package:flutter/cupertino.dart';

import 'message_view.dart';

import '../messaging/mclient.dart';
import '../models/home.dart';

class HistoryView extends StatefulWidget {
  final Home home;
  final MClient client;

  const HistoryView({required this.home, required this.client, super.key});

  @override
  State<StatefulWidget> createState() => _HistoryView();
}

class _HistoryView extends State<HistoryView> {
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
      child: const Center(
        child: Text("Event history will be available soon."),
      ),
    );
  }
}
*/