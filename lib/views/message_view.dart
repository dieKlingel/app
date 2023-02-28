import 'package:flutter/cupertino.dart';

// TODO: send notification

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<StatefulWidget> createState() => _MessageView();
}

class _MessageView extends State<MessageView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("New Notification"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: null,
          child: Icon(CupertinoIcons.arrow_up_circle),
        ),
      ),
      child: Center(
        child: Text(
          "Sending a notification will be available soon.",
          style: TextStyle(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.label,
              context,
            ),
          ),
        ),
      ),
    );
  }
}
