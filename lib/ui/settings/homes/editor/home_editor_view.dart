import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'home_editor_view_model.dart';

class HomeEditorView extends StatefulWidget {
  const HomeEditorView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeEditorView();
}

class _HomeEditorView extends State<HomeEditorView> {
  @override
  Widget build(BuildContext context) {
    final name = context.select((HomeEditorViewModel vm) => vm.name);
    final server = context.select((HomeEditorViewModel vm) => vm.server);
    final username = context.select((HomeEditorViewModel vm) => vm.username);
    final password = context.select((HomeEditorViewModel vm) => vm.password);
    final channel = context.select((HomeEditorViewModel vm) => vm.channel);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: const Text("Home"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final vm = context.read<HomeEditorViewModel>();
            await vm.save();
            if (!mounted) {
              return;
            }
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          clipBehavior: Clip.none,
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text("Configuration"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Name"),
                  initialValue: name,
                  onChanged: (value) {
                    context.read<HomeEditorViewModel>().name = value;
                  },
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Server"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Server URL"),
                  initialValue: server,
                  onChanged: (value) {
                    context.read<HomeEditorViewModel>().server = value;
                  },
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Username"),
                  initialValue: username,
                  onChanged: (value) {
                    context.read<HomeEditorViewModel>().username = value;
                  },
                ),
                CupertinoTextFormFieldRow(
                  prefix: const Text("Password"),
                  initialValue: password,
                  obscureText: true,
                  onChanged: (value) {
                    context.read<HomeEditorViewModel>().password = value;
                  },
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Channel"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Channel Prefix"),
                  initialValue: channel,
                  onChanged: (value) {
                    context.read<HomeEditorViewModel>().channel = value;
                  },
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text("Doorunit"),
              children: [
                CupertinoTextFormFieldRow(
                  prefix: const Text("Passcode"),
                  obscureText: true,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
