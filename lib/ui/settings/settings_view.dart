import 'package:dieklingel_app/ui/home/home_view_model.dart';
import 'package:dieklingel_app/ui/settings/notifications/notifications_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/ice_server_list_view_bloc.dart';
import '../../repositories/home_repository.dart';
import '../../repositories/ice_server_repository.dart';
import 'about/about_view.dart';

import '../../views/ice_server_list_view.dart';
import 'homes/homes_view.dart';
import 'notifications/notifications_view.dart';

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
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => HomeViewModel(
                          context.read<HomeRepository>(),
                        ),
                        child: const HomesView(),
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
          if (!kIsWeb)
            CupertinoFormSection.insetGrouped(
              header: const Text("Notifications"),
              children: [
                CupertinoListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => NotificationsViewModel(),
                          child: const NotificationsView(),
                        ),
                      ),
                    );
                  },
                  leading: const Icon(
                    CupertinoIcons.bubble_left,
                    color: Colors.amber,
                  ),
                  title: const Text("Notifications"),
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
