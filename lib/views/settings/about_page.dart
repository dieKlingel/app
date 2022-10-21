import 'package:flutter/cupertino.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("About"),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            "© Kai Mayer 2022 Heilbronn",
            style: CupertinoTheme.of(context).textTheme.textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
