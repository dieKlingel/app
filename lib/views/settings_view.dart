import 'package:dieklingel_app/blocs/home_list_view_bloc.dart';
import 'package:dieklingel_app/blocs/ice_server_list_view_bloc.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'about_view.dart';
import 'ice_server_list_view.dart';

import '../components/cupertino_form_row_prefix.dart';
import '../views/home_list_view.dart';

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
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => BlocProvider(
                        bloc: HomeListViewBloc(),
                        child: const HomeListView(),
                      ),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "Homes",
                    icon: CupertinoIcons.home,
                    color: Colors.orange,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => BlocProvider(
                        bloc: IceServerListViewBloc(),
                        child: const IceServerListView(),
                      ),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "ICE Servers",
                    icon: CupertinoIcons.cloud,
                    color: Colors.blue,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: const Text("Information"),
            children: [
              CupertinoInkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AboutView(),
                    ),
                  );
                },
                child: const CupertinoFormRow(
                  prefix: CupertinoFormRowPrefix(
                    title: "About",
                    icon: CupertinoIcons.info_circle,
                    color: Colors.green,
                  ),
                  child: Icon(CupertinoIcons.forward),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
