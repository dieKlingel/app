import 'dart:html';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({Key? key}) : super(key: key);

  @override
  State<PreviewView> createState() => _PreviewView();
}

class _PreviewView extends State<PreviewView> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  double _scrollTopOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      setState(() {
        _scrollTopOffset = _scrollController.offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double minImageHeight = constraints.maxHeight / 2;
        double height = max(
          constraints.maxHeight - _scrollTopOffset,
          minImageHeight,
        );
        double margin = constraints.maxHeight - height;
        return ListView(
          controller: _scrollController,
          children: [
            Container(
              margin: EdgeInsets.only(top: margin),
              width: double.infinity,
              height: height,
              child: Image.network(
                "https://picsum.photos/250?image=9",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 65,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 14.0),
              child: Text("User Notification"),
            ),
            const Divider(
              color: Colors.black,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoTextField(
                autofocus: true,
                placeholder: "Title",
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoTextField(
                placeholder: "Message",
                maxLines: 3,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoButton.filled(
                onPressed: null,
                child: Text("send"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }
}
