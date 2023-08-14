import 'package:dieklingel_app/blocs/home_view_bloc.dart';
import 'package:dieklingel_app/states/call_state.dart';
import 'package:dieklingel_app/states/home_state.dart';
import 'package:dieklingel_app/views/call_view.dart';
import 'package:dieklingel_app/views/home_add_view.dart';
import 'package:dieklingel_app/views/ice_server_add_view.dart';
import 'package:dieklingel_app/views/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../blocs/call_view_bloc.dart';
import '../models/hive_home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _onAddHome(BuildContext context) async {
    final bloc = context.read<HomeViewBloc>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: HomeAddView(),
        );
      },
    );
    bloc.add(HomeRefresh());
  }

  void _onAddIceServer(BuildContext context) async {
    final bloc = context.read<HomeViewBloc>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: IceServerAddView(),
        );
      },
    );
    bloc.add(HomeRefresh());
  }

  void _onSettingsTap(BuildContext context) async {
    final bloc = context.read<HomeViewBloc>();
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
    bloc.add(HomeRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewBloc, HomeState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(state is HomeSelectedState ? state.home.name : "Home"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PullDownButton(
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      onTap: () => _onAddHome(context),
                      title: "add Home",
                      icon: CupertinoIcons.home,
                    ),
                    const PullDownMenuDivider(),
                    PullDownMenuItem(
                      onTap: () => _onAddIceServer(context),
                      title: "add ICE Server",
                      icon: CupertinoIcons.cloud,
                    )
                  ],
                  buttonBuilder: (context, showMenu) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: showMenu,
                    child: const Icon(CupertinoIcons.plus),
                  ),
                ),
                PullDownButton(
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      onTap: () => _onSettingsTap(context),
                      title: "Settings",
                      icon: CupertinoIcons.settings,
                    ),
                    if (state.homes.isNotEmpty) ...[
                      const PullDownMenuDivider.large(),
                    ],
                    for (HiveHome home in state.homes) ...[
                      PullDownMenuItem.selectable(
                        selected:
                            state is HomeSelectedState && home == state.home,
                        onTap: () {
                          context
                              .read<HomeViewBloc>()
                              .add(HomeSelected(home: home));
                          context.read<CallViewBloc>().add(CallHangup());
                        },
                        title: home.name,
                      ),
                      if (home != state.homes.last) ...[
                        const PullDownMenuDivider()
                      ],
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
      },
    );
  }
}

class _Content extends StatelessWidget {
  void _onAddHome(BuildContext context) async {
    final bloc = context.read<HomeViewBloc>();
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: HomeAddView(),
        );
      },
    );
    bloc.add(HomeRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewBloc, HomeState>(
      builder: ((context, state) {
        if (state is! HomeSelectedState) {
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
        return const CallView();
      }),
    );
  }
}
