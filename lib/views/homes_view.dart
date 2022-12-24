import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/components/home_preview.dart';
import 'package:dieklingel_app/components/rtc_video_renderer.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/rtc/mqtt_rtc_client.dart';
import 'package:dieklingel_app/view_models/homes_view_model.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import 'home_view.dart';

@injectable
class HomesView extends StatefulWidget {
  const HomesView({Key? key}) : super(key: key);

  @override
  State<HomesView> createState() => _HomePage();
}

class _HomePage extends State<HomesView> {
  final HomesViewModel vm = GetIt.I.get<HomesViewModel>();

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

  void _onHomeTitleBtnPressed(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: List.generate(
          vm.homes.length,
          (index) {
            Home home = vm.homes[index];

            return CupertinoActionSheetAction(
              isDefaultAction: home == vm.home,
              onPressed: () {
                vm.home = home;
                Navigator.pop(context);
              },
              child: Text(home.name),
            );
          },
        )..add(
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              isDestructiveAction: true,
              child: const Text("Cancel"),
            ),
          ),
      ),
    );
  }

  void _onSettingsBtnPressed() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
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
    Navigator.push(context,
        CupertinoPageRoute(builder: ((context) => HomeView(home: home))));
  }

  Widget _body(BuildContext context) {
    List<Home> homes = context.watch<HomesViewModel>().homes;

    return SliverSafeArea(
      top: false,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: homes.length,
          (context, index) {
            Home home = homes[index];

            return Padding(
              padding: EdgeInsets.all(10.0),
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
                      Icon(CupertinoIcons.chevron_forward),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _preview(BuildContext context) {
    MqttRtcClient? client = context.watch<HomesViewModel>().rtc;
    if (client == null) {
      return Container(
        height: 10,
        color: Colors.red,
      );
    }
    return RtcVideoRenderer(client.rtcVideoRenderer);
  }

  Widget _shortcuts(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            CupertinoButton(
              child: Text("connect"),
              onPressed: () => vm.connectRTC(),
            ),
            CupertinoButton(
              child: Text("disconnect"),
              onPressed: () => vm.disconnectRTC(),
            ),
            //CupertinoButton(child: Text("unlock"), onPressed: () {}),
            CupertinoButton(
              child: Text("[DEBUG] reconnect"),
              onPressed: () => vm.connect(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      builder: (context, child) => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            _header(context),
            _body(context),
          ],
        ),
      ),
    );
  }
}
