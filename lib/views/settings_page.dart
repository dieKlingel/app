import 'package:dieklingel_app/views/settings/about_page.dart';
import 'package:dieklingel_app/views/settings/ice_servers_view.dart';
import 'package:dieklingel_app/views/settings/notifications_page.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/cupertino_form_row_prefix.dart';
import 'settings/licenses_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Settings"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: const Text("Connections"),
            children: [
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const IceServersView(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "ICE Servers",
                    icon: CupertinoIcons.cloud,
                    color: Colors.blue,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "Notifications",
                    icon: CupertinoIcons.bell_fill,
                    color: Colors.red,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: const Text("Information"),
            children: [
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "About",
                    icon: CupertinoIcons.info_circle,
                    color: Colors.green,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const LicensesPage(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "Licenses",
                    icon: CupertinoIcons.chevron_left_slash_chevron_right,
                    color: Colors.lightBlue,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
