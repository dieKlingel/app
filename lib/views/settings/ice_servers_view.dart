import 'package:dieklingel_app/models/ice_server.dart';
import 'package:dieklingel_app/views/ice_server_add_view.dart';
import 'package:dieklingel_app/views/settings/ice_servers_view_model.dart';
import 'package:dieklingel_app/views/sheets/ice_server_config_sheet.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IceServersView extends StatefulWidget {
  const IceServersView({super.key});

  @override
  State<StatefulWidget> createState() => _IceServersPage();
}

class _IceServersPage extends State<IceServersView> {
  Widget _listview(BuildContext context) {
    IceServersViewModel vm = context.watch<IceServersViewModel>();

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: vm.servers.isEmpty
          ? Container()
          : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CupertinoFormSection(
                children: List.generate(
                  vm.servers.length,
                  (index) {
                    IceServer server = vm.servers[index];

                    return Dismissible(
                      background: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => vm.delete(server),
                      key: UniqueKey(), //Key(server.uuid!),
                      child: CupertinoInkWell(
                        onTap: () async {
                          IceServer? result = await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  IceServerConfigSheet(server: server),
                            ),
                          );
                          if (result == null) return;
                          vm.insert(result);
                        },
                        child: CupertinoFormRow(
                          padding: const EdgeInsets.all(12),
                          prefix: Text(server.urls),
                          child: const Icon(CupertinoIcons.forward),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    IceServersViewModel vm = context.watch<IceServersViewModel>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("ICE Servers"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            IceServer? server = await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const IceServerConfigSheet(),
              ),
            );
            if (server == null) return;
            vm.insert(server);
          },
          child: const Icon(
            CupertinoIcons.plus,
          ),
        ),
      ),
      child: SafeArea(
        child: _listview(context),
      ),
    );
  }
}
