import 'package:dieklingel_app/blocs/home_list_view_bloc.dart';
import 'package:dieklingel_app/blocs/home_view_bloc.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:dieklingel_app/states/home_list_state.dart';
import 'package:dieklingel_app/states/home_state.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/hive_home.dart';
import 'home_add_view.dart';

class HomeListView extends StatelessWidget {
  const HomeListView({super.key});

  void _onAddHome(BuildContext context) async {
    final bloc = context.read<HomeListViewBloc>();
    await Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => const CupertinoPopupSurface(
          child: HomeAddView(),
        ),
      ),
    );
    bloc.add(HomeListRefresh());
  }

  void _onEditHome(BuildContext context, HiveHome home) async {
    final bloc = context.read<HomeListViewBloc>();

    await Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => CupertinoPopupSurface(
          child: HomeAddView(
            home: home,
          ),
        ),
      ),
    );
    bloc.add(HomeListRefresh());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Home"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _onAddHome(context),
        ),
      ),
      child: SafeArea(child: BlocBuilder<HomeListViewBloc, HomeListState>(
        builder: (context, state) {
          if (state.homes.isEmpty) {
            return Center(
              child: CupertinoButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.add),
                    Text("add your first Home"),
                  ],
                ),
                onPressed: () => _onAddHome(context),
              ),
            );
          }

          return CupertinoListSection.insetGrouped(
            children: [
              for (HiveHome home in state.homes) ...[
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
                        .read<HomeListViewBloc>()
                        .add(HomeListDeleted(home: home));
                  },
                  child: CupertinoListTile(
                    title: Text(home.name),
                    onTap: () => _onEditHome(context, home),
                    leading: const Icon(CupertinoIcons.home),
                    trailing: const Icon(CupertinoIcons.chevron_forward),
                  ),
                ),
              ],
            ],
          );
        },
      )

          /* StreamBuilder(
        stream: context.bloc<HomeListViewBloc>().homes,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<HiveHome>> snapshot,
        ) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: CupertinoActivityIndicator(),
            );
          }

          List<HiveHome> homes = snapshot.data!;

          return ListView.builder(
            itemCount: homes.length,
            itemBuilder: (context, index) {
              HiveHome home = homes[index];

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
                onDismissed: (direction) async {
                  await home.delete();
                },
                child: CupertinoInkWell(
                  onTap: () => _onHomeEditViewPressed(context, home),
                  child: CupertinoFormRow(
                    prefix: Text(home.name),
                    child: const Icon(CupertinoIcons.forward),
                  ),
                ),
              );
            },
          );
        },
      )),*/
          ),
    );
  }
}
