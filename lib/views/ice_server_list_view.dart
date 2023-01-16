import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'ice_server_add_view.dart';

import '../models/ice_server.dart';
import '../view_models/ice_server_list_view_model.dart';

class IceServerListView extends StatefulWidget {
  const IceServerListView({super.key});

  @override
  State<IceServerListView> createState() => _IceServerListView();
}

class _IceServerListView extends State<IceServerListView> {
  final IceServerListViewModel _vm = IceServerListViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IceServerListViewModel>(
      create: (context) => _vm,
      builder: (context, child) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("ICE Server's"),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const IceServerAddView(),
                ),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Consumer<IceServerListViewModel>(
            builder: (context, vm, child) => ListView.builder(
              itemCount: vm.servers.length,
              itemBuilder: (context, index) {
                IceServer server = vm.servers[index];

                return Dismissible(
                  key: UniqueKey(),
                  child: CupertinoInkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              IceServerAddView(server: server),
                        ),
                      );
                    },
                    child: CupertinoFormRow(
                      prefix: Text(server.urls),
                      child: const Icon(CupertinoIcons.forward),
                    ),
                  ),
                  onDismissed: (direction) async {
                    await server.delete();
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
