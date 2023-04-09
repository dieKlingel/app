import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("About"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Legal Notice & Privacy Policy"),
              children: [
                CupertinoListTile(
                  title: const Text("Legal Notice"),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://dieklingel.de/credit-notes"),
                    );
                  },
                ),
                CupertinoListTile(
                  title: const Text("Privacy Policy"),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://dieklingel.de/privacy-policy"),
                    );
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "© Kai Mayer 2023 Heilbronn",
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
