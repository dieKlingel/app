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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.home.name),
      ),
      child: Text("a"),
    );
  }
}
