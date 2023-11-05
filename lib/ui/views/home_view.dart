import 'package:dieklingel_app/ui/view_models/core_view_model.dart';
import 'package:dieklingel_app/ui/view_models/home_view_model.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/ui/views/core_view.dart';
import 'package:dieklingel_app/views/home_add_view.dart';
import 'package:dieklingel_app/views/ice_server_add_view.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../blocs/call_view_bloc.dart';
import '../../models/hive_home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _onAddHome(BuildContext context) async {
    final homeViewModel = context.read<HomeViewModel>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: HomeAddView(),
        );
      },
    );
    await homeViewModel.refresh();
  }

  void _onAddIceServer(BuildContext context) async {
    final homeViewModel = context.read<HomeViewModel>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: IceServerAddView(),
        );
      },
    );
    homeViewModel.refresh();
  }

  void _onSettingsTap(BuildContext context) async {
    final homeViewModel = context.read<HomeViewModel>();
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
    await homeViewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        context.select<HomeViewModel, HiveHome?>((value) => value.home)?.name ??
            "Home";
    final homes =
        context.select<HomeViewModel, List<HiveHome>>((value) => value.homes);

    final selectedHome =
        context.select<HomeViewModel, HiveHome?>((value) => value.home);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AppBarAddButton(
              addHomeFunc: _onAddHome,
              addIceServerFunc: _onAddIceServer,
            ),
            PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  onTap: () => _onSettingsTap(context),
                  title: "Settings",
                  icon: CupertinoIcons.settings,
                ),
                if (homes.isNotEmpty) ...[
                  const PullDownMenuDivider.large(),
                ],
                for (HiveHome home in homes) ...[
                  PullDownMenuItem.selectable(
                    selected: selectedHome == home,
                    onTap: () {
                      //context.read<HomeViewModel>().home = home;
                      context.read<CallViewBloc>().add(CallHangup());
                    },
                    title: home.name,
                  ),
                  if (home != homes.last) ...[const PullDownMenuDivider()],
                ]
              ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: showMenu,
                child: const Icon(CupertinoIcons.ellipsis_circle),
              ),
            ),
          ],
        ),
      ),
      child: _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  void _onAddHome(BuildContext context) async {
    final homeViewModel = context.read<HomeViewModel>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: HomeAddView(),
        );
      },
    );
    homeViewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    HiveHome? home =
        context.select<HomeViewModel, HiveHome?>((value) => value.home);

    if (home == null) {
      return Center(
        child: CupertinoButton(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.add),
              Text("add your first Home"),
            ],
          ),
          onPressed: () => _onAddHome(context),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => CoreViewModel(home, MqttClient(home.uri)),
      child: const CoreView(),
    );
  }
}

class _AppBarAddButton extends StatelessWidget {
  final Function(BuildContext) addHomeFunc;
  final Function(BuildContext) addIceServerFunc;

  const _AppBarAddButton({
    required this.addHomeFunc,
    required this.addIceServerFunc,
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () => addHomeFunc(context),
          title: "add Home",
          icon: CupertinoIcons.home,
        ),
        const PullDownMenuDivider(),
        PullDownMenuItem(
          onTap: () => addIceServerFunc(context),
          title: "add ICE Server",
          icon: CupertinoIcons.cloud,
        )
      ],
      buttonBuilder: (context, showMenu) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: showMenu,
        child: const Icon(CupertinoIcons.plus),
      ),
    );
  }
}
