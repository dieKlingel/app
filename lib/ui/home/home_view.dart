import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../components/core_home_widget.dart';
import '../../components/fade_page_route.dart';
import '../../models/home.dart';
import '../../repositories/home_repository.dart';
import '../../repositories/ice_server_repository.dart';
import '../../views/ice_server_add_view.dart';
import '../call/outgoing/call_outgoing_view.dart';
import '../call/outgoing/call_outgoing_view_model.dart';
import '../settings/homes/editor/home_editor_view.dart';
import '../settings/homes/editor/home_editor_view_model.dart';
import '../settings/settings_view.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _onAddHome(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoPopupSurface(
          child: ChangeNotifierProvider(
            create: (_) => HomeEditorViewModel(
              context.read<HomeRepository>(),
            ),
            child: const HomeEditorView(),
          ),
        );
      },
    );
  }

  void _onAddIceServer(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return const CupertinoPopupSurface(
          child: IceServerAddView(),
        );
      },
    );
  }

  void _onSettingsTap(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Homes"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AppBarAddButton(
              addHomeFunc: _onAddHome,
              addIceServerFunc: _onAddIceServer,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _onSettingsTap(context),
              child: const Icon(CupertinoIcons.settings),
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
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoPopupSurface(
          child: ChangeNotifierProvider(
            create: (_) => HomeEditorViewModel(
              context.read<HomeRepository>(),
            ),
            child: const HomeEditorView(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<(Home, mqtt.Client)> connections =
        context.select<HomeViewModel, List<(Home, mqtt.Client)>>(
      (value) => value.connections,
    );

    if (connections.isEmpty) {
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

    return ListView.builder(
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final (home, client) = connections[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CoreHomeWidget(
            home: home,
            client: client,
            onCallPressed: () {
              Navigator.of(context).push(
                FadePageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => CallOutgoingViewModel(
                      iceServerRepository: context.read<IceServerRepository>(),
                      home: home,
                      connection: client,
                    ),
                    child: const CallOutgoingView(),
                  ),
                ),
              );
            },
          ),
        );
      },
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
