import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/ui/settings/homes/editor/home_editor_view.dart';
import 'package:dieklingel_app/ui/settings/homes/editor/home_editor_view_model.dart';
import 'package:dieklingel_app/ui/settings/homes/homes_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../models/home.dart';
import 'widgets/list_entry.dart';

class HomesView extends StatelessWidget {
  const HomesView({super.key});

  void _onEditHome(BuildContext context, [Home? home]) async {
    await Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => CupertinoPopupSurface(
          child: ChangeNotifierProvider(
            create: (_) => HomeEditorViewModel(
              context.read<HomeRepository>(),
              home: home,
            ),
            child: const HomeEditorView(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Home"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _onEditHome(context),
        ),
      ),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final homes = context.select(
              (HomesViewModel vm) => vm.homes,
            );

            if (homes.isEmpty) {
              return Center(
                child: CupertinoButton(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.add),
                      Text("add your first Home"),
                    ],
                  ),
                  onPressed: () => _onEditHome(context),
                ),
              );
            }

            return ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  children: List.generate(
                    homes.length,
                    (index) {
                      final home = homes[index];
                      return ListEntry(
                        home: home,
                        onTap: () => _onEditHome(context, home),
                        onDismiss: () {
                          final vm = context.read<HomesViewModel>();
                          vm.deleteHome(home);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
