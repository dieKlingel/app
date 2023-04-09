import 'package:dieklingel_app/blocs/ice_server_list_view_bloc.dart';
import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_app/states/icer_server_list_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ice_server_add_view.dart';

class IceServerListView extends StatelessWidget {
  const IceServerListView({super.key});

  void _onIceServerEdit(BuildContext context, [HiveIceServer? server]) async {
    final bloc = context.read<IceServerListViewBloc>();

    await Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => CupertinoPopupSurface(
          child: IceServerAddView(
            server: server,
          ),
        ),
      ),
    );
    bloc.add(IceServerListRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text("ICE Server's"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _onIceServerEdit(context),
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<IceServerListViewBloc, IceServerListState>(
          builder: (context, state) {
            if (state.servers.isEmpty) {
              return Center(
                child: CupertinoButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(CupertinoIcons.add),
                      Text("add your first ICE Server"),
                    ],
                  ),
                  onPressed: () => _onIceServerEdit(context),
                ),
              );
            }

            return ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  children: [
                    for (HiveIceServer server in state.servers) ...[
                      Dismissible(
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
                        onDismissed: (direction) async {
                          context
                              .read<IceServerListViewBloc>()
                              .add(IceServerListDeleted(server: server));
                        },
                        child: CupertinoListTile(
                          title: Text(server.urls),
                          onTap: () => _onIceServerEdit(context, server),
                          leading: const Icon(CupertinoIcons.cloud),
                          trailing: const Icon(CupertinoIcons.chevron_forward),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
