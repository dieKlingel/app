import 'package:dieklingel_app/views/settings/about/privacy_policy_page.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
                CupertinoInkWell(
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://dieklingel.de/credit-notes"),
                    );
                  },
                  child: const CupertinoFormRow(
                    padding: EdgeInsets.all(12.0),
                    prefix: Text("Legal Notice"),
                    child: Icon(CupertinoIcons.forward),
                  ),
                ),
                CupertinoInkWell(
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://dieklingel.de/privacy-policy"),
                    );
                  },
                  child: const CupertinoFormRow(
                    padding: EdgeInsets.all(12.0),
                    prefix: Text("Privacy Policy"),
                    child: Icon(CupertinoIcons.forward),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "© Kai Mayer 2022 Heilbronn",
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
