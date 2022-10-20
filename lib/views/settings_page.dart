import 'package:dieklingel_app/views/settings/homes_page.dart';
import 'package:dieklingel_app/views/settings/ice_servers_page.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                      builder: (context) => const HomesPage(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: PrefixWidget(
                    title: "Homes",
                    icon: CupertinoIcons.house,
                    color: Colors.orange,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const IceServersPage(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: PrefixWidget(
                    title: "ICE Servers",
                    icon: CupertinoIcons.cloud,
                    color: Colors.blue,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
              const CupertinoFormRow(
                prefix: PrefixWidget(
                  title: "Sound",
                  icon: CupertinoIcons.bell_fill,
                  color: Colors.red,
                ),
                child: Icon(CupertinoIcons.forward),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: const Text("Information"),
            children: const [
              CupertinoFormRow(
                prefix: PrefixWidget(
                  title: "About",
                  icon: CupertinoIcons.info_circle,
                  color: Colors.green,
                ),
                child: Icon(CupertinoIcons.forward),
              ),
              CupertinoFormRow(
                prefix: PrefixWidget(
                  title: "Licenses",
                  icon: CupertinoIcons.chevron_left_slash_chevron_right,
                  color: Colors.lightBlue,
                ),
                child: Icon(CupertinoIcons.forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrefixWidget extends StatelessWidget {
  const PrefixWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: CupertinoColors.white),
        ),
        const SizedBox(width: 15),
        Text(title)
      ],
    );
  }
}
