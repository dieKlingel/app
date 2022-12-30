import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<StatefulWidget> createState() => _MessageView();
}

class _MessageView extends State<MessageView> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("New Notification"),
      ),
      child: Center(
        // TODO: add content
        child: Text("send a messsage"),
      ),
    );
  }
}
