import 'package:dieklingel_app/models/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'message_view.dart';

class HistoryView extends StatefulWidget {
  final Home home;
  const HistoryView({required this.home, super.key});

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
      child: Center(
        child: Text("History: ${widget.home.name}"),
      ),
    );
  }
}
