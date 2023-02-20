/* import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'home_add_view.dart';

import '../models/home.dart';
import '../view_models/home_list_view_model.dart';

class HomeListView extends StatelessWidget {
  const HomeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeListViewModel>(
      create: (context) => HomeListViewModel(),
      builder: (context, child) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Home"),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const HomeAddView(),
                ),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Consumer<HomeListViewModel>(
            builder: (context, vm, child) => ListView.builder(
              itemCount: vm.homes.length,
              itemBuilder: (context, index) {
                Home home = vm.homes[index];

                return Dismissible(
                  key: UniqueKey(),
                  child: CupertinoInkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HomeAddView(home: home),
                        ),
                      );
                    },
                    child: CupertinoFormRow(
                      prefix: Text(home.name),
                      child: const Icon(CupertinoIcons.forward),
                    ),
                  ),
                  onDismissed: (direction) async {
                    await home.delete();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
*/