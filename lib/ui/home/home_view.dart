import 'package:dieklingel_app/ui/home/widgets/app_bar_add.dart';
import 'package:dieklingel_app/ui/home/widgets/app_bar_menu.dart';
import 'package:dieklingel_app/ui/home/widgets/home_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/home.dart';
import '../../repositories/home_repository.dart';
import '../settings/homes/editor/home_editor_view.dart';
import '../settings/homes/editor/home_editor_view_model.dart';
import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Home? selected;

  @override
  void initState() {
    setState(() {
      selected = context.read<HomeViewModel>().homes.firstOrNull;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homes = context.select(
      (HomeViewModel vm) => vm.homes,
    );
    if (!homes.contains(selected)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selected = homes.first;
        });
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(selected?.name ?? "Homes"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBarAdd(),
            AppBarMenu(
              homes: homes,
              selected: selected,
              onHomeTap: (home) {
                setState(() {
                  selected = home;
                });
              },
              onReconnectTap: (home) {
                context.read<HomeViewModel>().reconnect(home);
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

        if (selected == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              selected = homes.first;
            });
          });
          return const CupertinoActivityIndicator();
        }

        return HomeBody(home: selected!);
      }),
    );
  }
}
