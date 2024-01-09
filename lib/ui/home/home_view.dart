import 'package:dieklingel_app/ui/home/widgets/app_bar_add.dart';
import 'package:dieklingel_app/ui/home/widgets/app_bar_menu.dart';
import 'package:dieklingel_app/ui/home/widgets/home_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../repositories/home_repository.dart';
import '../settings/homes/editor/home_editor_view.dart';
import '../settings/homes/editor/home_editor_view_model.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homes = context.select(
      (HomeViewModel vm) => vm.homes,
    );
    final home = context.select((HomeViewModel vm) => vm.home);

    if (homes.isNotEmpty && home == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeViewModel>().home = homes.first;
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(home?.name ?? "Homes"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBarAdd(),
            AppBarMenu(
              homes: homes,
              selected: home,
              onHomeTap: (home) {
                final vm = context.read<HomeViewModel>();
                vm.home = home;
                vm.reconnect();
              },
              onReconnectTap: (home) {
                context.read<HomeViewModel>().reconnect();
              },
            ),
          ],
        ),
      ),
      child: Builder(builder: (context) {
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
              onPressed: () {
                showCupertinoModalPopup(
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
              },
            ),
          );
        }

        if (home == null) {
          return const CupertinoActivityIndicator();
        }

        return HomeBody(home: home);
      }),
    );
  }
}
