import 'package:flutter/cupertino.dart';

import 'call_view.dart';
import 'history_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: const [
        BottomNavigationBarItem(
          label: "Home",
          icon: Icon(CupertinoIcons.home),
        ),
        BottomNavigationBarItem(
          label: "History",
          icon: Icon(CupertinoIcons.collections),
        ),
      ]),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const CallView();
          case 1:
            return const HistoryView();
        }

        return const Center(
          child: Text("Ooops :("),
        );
      },
    );
  }
}
