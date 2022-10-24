import 'package:flutter/cupertino.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Privacy Policy"),
      ),
      child: SafeArea(
        child: Text("comming soon..."),
      ),
    );
  }
}
