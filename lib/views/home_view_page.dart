import 'settings/settings_view_page.dart';

import 'preview_view_page.dart';
import 'package:flutter/cupertino.dart';

enum TabBarPages {
  preview(
    PreviewViewPage(),
  ),
  settings(
    SettingsViewPage(),
  );

  final Widget page;

  const TabBarPages(this.page);
}

class HomeViewPage extends StatelessWidget {
  const HomeViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
              size: 24,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.settings,
              size: 24,
            ),
            label: "Settings",
          )
        ],
      ),
      tabBuilder: (context, index) {
        return TabBarPages.values[index].page;
      },
    );
  }
}
