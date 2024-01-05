import 'package:dieklingel_app/ui/settings/notifications/notifications_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool enabled = context.select((NotificationsViewModel vm) => vm.enabled);
    String? token = context.select((NotificationsViewModel vm) => vm.token);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Notifications"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Notifications"),
              children: [
                CupertinoListTile(
                  title: const Text("Enabled"),
                  trailing: CupertinoSwitch(
                    onChanged: (value) {
                      final vm = context.read<NotificationsViewModel>();
                      vm.enabled = value;
                    },
                    value: enabled,
                  ),
                ),
                if (token != null)
                  CupertinoTextFormFieldRow(
                    prefix: const Text("Token"),
                    initialValue: token,
                    readOnly: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
