import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/view_models/home_view_model.dart';
import 'package:dieklingel_app/views/home_add_view.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

@injectable
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomePage();
}

class _HomePage extends State<HomeView> {
  final HomeViewModel vm = GetIt.I.get<HomeViewModel>();

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
      largeTitle: _title(context),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.settings),
        onPressed: () => _onSettingsBtnPressed(),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return GestureDetector(
      onTap: () => _onHomeTitleBtnPressed(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              context.watch<HomeViewModel>().home?.name ?? "No Home!",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          //if (context.watch<HomeViewModel>().homes.length > 1)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.chevron_down),
          )
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        _shortcuts(context),
        Text(context.watch<HomeViewModel>().client.state.toString()),
      ]),
    );
  }

  Widget _preview(BuildContext context) {
    throw UnimplementedError();
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
