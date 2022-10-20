import 'home_page.dart';
import 'settings_page.dart';
import 'package:flutter/cupertino.dart';

enum TabBarPages {
  preview(
    HomePage(),
  ),
  settings(
    SettingsPage(),
  );

  final Widget page;

  const TabBarPages(this.page);
}

class TabbarPage extends StatelessWidget {
  const TabbarPage({Key? key}) : super(key: key);

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
