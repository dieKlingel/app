import 'dart:convert';
import 'dart:ffi';

import 'package:dieklingel_app/components/radio_box.dart';
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

  Key? selectedConfigurationKey;
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
      selectedConfigurationKey = configurations
          .firstWhere(
            (element) => element.isDefault,
            orElse: () => configurations.first,
          )
          .key;
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
            ConnectionConfiguration configuration = configurations[i];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: i == 0
                      ? BorderSide(
                          color: const CupertinoDynamicColor.withBrightness(
                            color: CupertinoColors.lightBackgroundGray,
                            darkColor: CupertinoColors.secondaryLabel,
                          ).resolveFrom(context),
                        )
                      : BorderSide.none,
                  bottom: BorderSide(
                    color: const CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.lightBackgroundGray,
                      darkColor: CupertinoColors.secondaryLabel,
                    ).resolveFrom(context),
                  ),
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
                key: configuration.key,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          RadioBox(
                            value:
                                configuration.key != selectedConfigurationKey,
                            onChanged: (state) {
                              setState(() {
                                configurations
                                    .firstWhere((element) =>
                                        element.key == selectedConfigurationKey)
                                    .isDefault = false;
                                selectedConfigurationKey = configuration.key;
                                configuration.isDefault = true;
                                print(configurations);
                                setConfigurations(configurations);
                              });
                            },
                          ),
                          Text(
                            configurations[i].description,
                            style: TextStyle(
                              color: const CupertinoDynamicColor.withBrightness(
                                color: CupertinoColors.black,
                                darkColor: CupertinoColors.white,
                              ).resolveFrom(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      child: Icon(
                        CupertinoIcons.forward,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ConnectionConfigurationView(
                              configuration: configuration,
                            ),
                          ),
                        );
                        refreshList();
                      },
                    ),
                  ],
                ),
                onDismissed: (DismissDirection direction) async {
                  configurations.removeAt(i);
                  await setConfigurations(configurations);
                  if (configurations.isEmpty) {
                    Navigator.popUntil(context, (route) {
                      if (!route.isFirst) {
                        Navigator.replaceRouteBelow(
                          context,
                          anchorRoute: route,
                          newRoute: CupertinoPageRoute(
                            builder: (context) => ConnectionConfigurationView(),
                          ),
                        );
                      }
                      return route.isFirst;
                    });
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
