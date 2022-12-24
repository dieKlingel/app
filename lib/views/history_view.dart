import 'package:dieklingel_app/models/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  final Home home;
  const HistoryView({required this.home, super.key});

  @override
  State<StatefulWidget> createState() => _HistoryView();
}

class _HistoryView extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.home.name),
      ),
      child: Center(
        child: Text("History: ${widget.home.name}"),
      ),
    );
  }
}
