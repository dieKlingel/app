import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/views/call_view.dart';
import 'package:dieklingel_app/views/history_view.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final Home home;

  const HomeView({required this.home, super.key});

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
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
            return CallView(
              home: widget.home,
            );
          case 1:
            return HistoryView(
              home: widget.home,
            );
        }

        return const Center(
          child: Text("Ooops :("),
        );
      },
    );
  }
}
