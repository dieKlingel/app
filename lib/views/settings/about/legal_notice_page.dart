import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Legal Notice"),
        ),
        child: SafeArea(
          child: Text("comming soon ..."),
        ));
  }
}
