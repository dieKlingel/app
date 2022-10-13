import 'package:flutter/cupertino.dart';

import 'preview_view.dart';
import 'settings/settings_view_page.dart';

class PreviewViewPage extends StatelessWidget {
  const PreviewViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.text_badge_plus,
          ),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const SettingsViewPage(),
              ),
            );
          }, //callIsActive ? null : ,
        ),
      ),
      child: const SafeArea(
        child: PreviewView(),
      ),
    );
  }
}
