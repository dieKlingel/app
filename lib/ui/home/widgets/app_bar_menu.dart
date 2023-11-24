import 'package:dieklingel_app/ui/settings/settings_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../models/home.dart';

class AppBarMenu extends StatelessWidget {
  final Home? selected;
  final List<Home> homes;
  final void Function(Home) onHomeTap;
  final void Function(Home) onReconnectTap;

  const AppBarMenu({
    super.key,
    required this.onHomeTap,
    required this.onReconnectTap,
    required this.homes,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const SettingsView(),
              ),
            );
          },
          title: "Settings",
          icon: CupertinoIcons.settings,
        ),
        if (homes.isNotEmpty) const PullDownMenuDivider.large(),
        for (final home in homes) ...[
          PullDownMenuItem.selectable(
            onTap: () => onHomeTap(home),
            title: home.name,
            selected: home == selected,
          ),
        ],
        if (selected != null) ...[const PullDownMenuDivider.large()],
        if (selected != null)
          PullDownMenuItem(
            onTap: () => onReconnectTap(selected!),
            title: "Reconnect",
            icon: CupertinoIcons.refresh,
          ),
      ],
      buttonBuilder: (context, showMenu) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: showMenu,
        child: const Icon(CupertinoIcons.ellipsis_circle),
      ),
    );
  }
}
