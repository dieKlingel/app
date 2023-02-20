import 'package:flutter/cupertino.dart';

import 'call_view.dart';
import 'history_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    /* try {
      await _client.connect(widget.home.uri);
    } catch (e) {
      // TODO: handle exception
    }*/
  }

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
