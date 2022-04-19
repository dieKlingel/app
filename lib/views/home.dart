import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("dieKlingel"),
        ),
        child: Center(
            child: Row(
          children: const [
            Text("124",
                style: TextStyle(
                  color: Colors.red,
                ))
          ],
        )));
  }
}
