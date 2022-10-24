import 'package:flutter/cupertino.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Licenses"),
      ),
      child: SafeArea(
        child: Text("licenses"),
      ),
    );
  }
}
