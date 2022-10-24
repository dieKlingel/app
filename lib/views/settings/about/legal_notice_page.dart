import 'package:flutter/cupertino.dart';

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Legal Notice"),
        ),
        child: SafeArea(
          child: Text("comming soon ..."),
        ));
  }
}
