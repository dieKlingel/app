import 'package:dieklingel_app/view_models/home_view_model.dart';

import 'home_view.dart';
import 'settings_view.dart';
import 'package:flutter/cupertino.dart';

/* enum TabBarPages {
  preview(
    HomeView(vm: HomeViewModel()),
  ),
  settings(
    SettingsPage(),
  );

  final Widget page;

  TabBarPages(this.page);
} */

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
        return Text("tabbar"); //TabBarPages.values[index].page;
      },
    );
  }
}
