import 'package:dieklingel_app/blocs/ice_server_list_view_bloc.dart';
import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ice_server_add_view.dart';

class IceServerListView extends StatelessWidget {
  const IceServerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
        child: StreamBuilder(
          stream: context.bloc<IceServerListViewBloc>().servers,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<HiveIceServer>> snapshot,
          ) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CupertinoActivityIndicator(),
              );
            }

            List<HiveIceServer> servers = snapshot.data!;

            return ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                HiveIceServer server = servers[index];

                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        CupertinoIcons.trash,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  direction: DismissDirection.endToStart,
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
            );
          },
        ),
      ),
    );
  }
}
