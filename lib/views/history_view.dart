import 'package:flutter/cupertino.dart';

import 'message_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

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
        middle: const Text("Comming soon!"),
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
