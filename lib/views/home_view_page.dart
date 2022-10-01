import 'package:dieklingel_app/views/call_view_page.dart';
import 'package:dieklingel_app/views/preview_view_page.dart';
import 'package:flutter/cupertino.dart';

enum TabBarPages {
  call(
    CallViewPage(),
  ),
  preview(
    PreviewViewPage(),
  );

  final Widget page;

  const TabBarPages(this.page);
}

class HomeViewPage extends StatelessWidget {
  const HomeViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
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
                CupertinoIcons.captions_bubble,
                size: 24,
              ),
              label: "Preview",
            )
          ],
        ),
        tabBuilder: (context, index) {
          return TabBarPages.values[index].page;
        },
      ),
    );
  }
}
