import 'package:dieklingel_app/components/preferences.dart';
import 'package:dieklingel_app/views/components/cupertino_selection_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Preferences preferences = context.watch<Preferences>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Notifications"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Call"),
              footer: const Text(
                  "If incomming call is enabled, an incoming call is shown instead of a notification."),
              children: [
                CupertinoFormRow(
                  prefix: const Text("Incomming Call"),
                  child: CupertinoSwitch(
                    value:
                        preferences.getBool("incomming_call_enabled") ?? true,
                    onChanged: ((value) {
                      preferences.setBool("incomming_call_enabled", value);
                    }),
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Notification"),
              children: [
                CupertinoFormRow(
                  padding: const EdgeInsets.only(left: 15, top: 3, bottom: 3),
                  prefix: const Text("Sound"),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        preferences.getString("notification_sound") ??
                            "default",
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
