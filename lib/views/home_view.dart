import 'package:flutter/cupertino.dart';

import 'call_view.dart';
import 'history_view.dart';

import '../messaging/mclient.dart';
import '../models/home.dart';
import '../view_models/call_view_model.dart';

class HomeView extends StatefulWidget {
  final Home home;

  const HomeView({required this.home, super.key});

  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  final MClient _client = MClient();
  late final CallViewModel _callViewModel = CallViewModel(
    home: widget.home,
    mclient: _client,
  );

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    try {
      await _client.connect(widget.home.uri);
    } catch (e) {
      // TODO: handle exception
    }
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
            return CallView(vm: _callViewModel);
          case 1:
            return HistoryView(
              home: widget.home,
              client: _client,
            );
        }

        return const Center(
          child: Text("Ooops :("),
        );
      },
    );
  }
}
