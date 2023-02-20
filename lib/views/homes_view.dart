import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'home_view.dart';
import 'settings_view.dart';

import '../models/home.dart';

class HomesView extends StatefulWidget {
  const HomesView({
    Key? key,
  }) : super(key: key);

  @override
  State<HomesView> createState() => _HomePage();
}

class _HomePage extends State<HomesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _init());
  }

  void _init() async {
    /* TODO: Hotfix: AudioSession
    Do this, so the mic starts the first time we use navigator.mediaDevices
    caues by this issue: https://github.com/flutter-webrtc/flutter-webrtc/issues/1094
    */
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.speech());
    });
  }

  void _onSettingsBtnPressed() {
    /* Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );*/
  }

  Widget _header(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: const Text("Homes"),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.settings),
        onPressed: () => _onSettingsBtnPressed(),
      ),
    );
  }

  void _onHomePressed(BuildContext context, Home home) async {
    /* Navigator.push(context,
        CupertinoPageRoute(builder: ((context) => HomeView(home: home))));*/
  }

  Widget _body(BuildContext context) {
    return Text("center");

    /* return SliverSafeArea(
      top: false,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: homes.length,
          (context, index) {
            Home home = homes[index];

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () => _onHomePressed(context, home),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemBackground,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(home.name),
                      const Icon(CupertinoIcons.chevron_forward),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Text("build");
    /* return ChangeNotifierProvider.value(
      value: widget.vm,
      builder: (context, child) => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            _header(context),
            _body(context),
          ],
        ),
      ),
    );**/
  }
}
