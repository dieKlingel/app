import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'preview_view.dart';

class PreviewViewPage extends StatelessWidget {
  const PreviewViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("dieKlingel"),
      ),
      child: SafeArea(
        child: PreviewView(),
      ),
    );
  }
}
