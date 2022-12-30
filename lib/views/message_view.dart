import 'package:flutter/cupertino.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<StatefulWidget> createState() => _MessageView();
}

class _MessageView extends State<MessageView> {
  void _onNotificationSendPressed(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("New Notification"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.arrow_up_circle),
          onPressed: () => _onNotificationSendPressed(context),
        ),
      ),
      child: const Center(
        // TODO: add content
        child: Text("send a messsage"),
      ),
    );
  }
}
