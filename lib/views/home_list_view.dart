import 'package:dieklingel_app/blocs/home_list_view_bloc.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/hive_home.dart';
import 'home_add_view.dart';

class HomeListView extends StatelessWidget {
  const HomeListView({super.key});

  void _onHomeAddViewPressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const HomeAddView(),
      ),
    );
  }

  void _onHomeEditViewPressed(BuildContext context, HiveHome home) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => HomeAddView(home: home),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Home"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _onHomeAddViewPressed(context),
        ),
      ),
      child: SafeArea(
          child: StreamBuilder(
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
      )),
    );
  }
}
