import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/view_models/home_view_model.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomePage();
}

class _HomePage extends State<HomeView> {
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

  Widget _title(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) => CupertinoInkWell(
        onTap: vm.homes.length < 2
            ? null
            : (() {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    child: SafeArea(
                      top: false,
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        magnification: 1.22,
                        useMagnifier: true,
                        scrollController: FixedExtentScrollController(
                          initialItem:
                              vm.home == null ? 0 : vm.homes.indexOf(vm.home!),
                        ),
                        onSelectedItemChanged: (index) {
                          vm.home = vm.homes[index];
                        },
                        children: List.generate(vm.homes.length, (index) {
                          Home home = vm.homes[index];

                          return Text(home.name);
                        }),
                      ),
                    ),
                  ),
                );
              }),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.home?.name ?? "No Homes"),
            if (vm.homes.length > 1)
              const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.inactiveGray,
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            // TODO: make clickable
            largeTitle: _title(context),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () {},
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.settings),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SettingsView(),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
