import 'package:flutter/cupertino.dart';

Future<void> displaySimpleAlertDialog(
  BuildContext context,
  Widget title,
  Widget content, {
  String ok = "Ok",
}) async {
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: title,
      content: content,
      actions: [
        CupertinoDialogAction(
          child: Text(ok),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
