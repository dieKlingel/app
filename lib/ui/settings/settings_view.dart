import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/home_list_view_bloc.dart';
import '../../blocs/ice_server_list_view_bloc.dart';
import '../../repositories/home_repository.dart';
import '../../repositories/ice_server_repository.dart';
import 'about/about_view.dart';

import '../../views/home_list_view.dart';
import '../../views/ice_server_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Settings"),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: const Text("Connections"),
            children: [
              CupertinoListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => HomeListViewBloc(
                          context.read<HomeRepository>(),
                        ),
                        child: const HomeListView(),
                      ),
                    ),
                  );
                },
                leading: const Icon(
                  CupertinoIcons.home,
                  color: Colors.orange,
                ),
                title: const Text("Homes"),
                trailing: const Icon(CupertinoIcons.forward),
              ),
              CupertinoListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => IceServerListViewBloc(
                          context.read<IceServerRepository>(),
                        ),
                        child: const IceServerListView(),
                      ),
                    ),
                  );
                },
                leading: const Icon(
                  CupertinoIcons.cloud,
                  color: Colors.blue,
                ),
                title: const Text("ICE Servers"),
                trailing: const Icon(CupertinoIcons.forward),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: const Text("Information"),
            children: [
              CupertinoListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AboutView(),
                    ),
                  );
                },
                leading: const Icon(
                  CupertinoIcons.info_circle,
                  color: Colors.green,
                ),
                title: const Text("About"),
                trailing: const Icon(CupertinoIcons.forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
