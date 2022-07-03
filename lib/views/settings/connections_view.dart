import 'dart:convert';
import 'dart:ffi';

import 'package:dieklingel_app/views/settings/connection_configuration_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/connection_configuration.dart';

class ConnectionsView extends StatefulWidget {
  const ConnectionsView({Key? key}) : super(key: key);

  @override
  _ConnectionsView createState() => _ConnectionsView();
}

class _ConnectionsView extends State<ConnectionsView> {
  _ConnectionsView() : super() {
    refreshList();
  }

  List<ConnectionConfiguration> configurations =
      List<ConnectionConfiguration>.empty(growable: true);

  Future<List<ConnectionConfiguration>> getConfigurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawConnectionConfig = prefs.getStringList("configuration") ??
        List<String>.empty(growable: true);
    List<ConnectionConfiguration> connectionConfig = rawConnectionConfig
        .map((config) => ConnectionConfiguration.fromJson(jsonDecode(config)))
        .toList(growable: true);
    return connectionConfig;
  }

  Future<void> setConfigurations(
    List<ConnectionConfiguration> configuration,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawConnectionConfig =
        configuration.map((config) => config.toString()).toList();
    prefs.setStringList("configuration", rawConnectionConfig);
  }

  void refreshList() async {
    List<ConnectionConfiguration> configurations = await getConfigurations();
    setState(() {
      this.configurations = configurations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: CupertinoButton(
          child: const Icon(
            CupertinoIcons.add,
            size: 16,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) =>
                    ConnectionConfigurationView(),
              ),
            );
            refreshList();
          },
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView.builder(
          itemCount: configurations.length,
          itemBuilder: (BuildContext context, int index) {
            ///if (index.isOdd) return const Divider();
            int i = index; //~/ 2;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: i == 0
                      ? BorderSide(color: Colors.grey.shade300)
                      : BorderSide.none,
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Dismissible(
                background: Container(
                  color: Colors.red,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      CupertinoIcons.delete_solid,
                      color: Colors.white,
                    ),
                  ),
                ),
                key: UniqueKey(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        configurations[i].description,
                        style: TextStyle(
                          color: CupertinoDynamicColor.withBrightness(
                            color: CupertinoColors.black,
                            darkColor: CupertinoColors.white,
                          ).resolveFrom(context),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      child: Icon(
                        CupertinoIcons.forward,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ConnectionConfigurationView(
                              configuration: configurations[i],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                onDismissed: (DismissDirection direction) async {
                  configurations.removeAt(i);
                  await setConfigurations(configurations);
                  if (configurations.isEmpty) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ConnectionConfigurationView(),
                        ),
                        (route) => false);
                  } else {
                    refreshList();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
