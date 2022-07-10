import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/connection_configuration.dart';
import '../../components/radio_box.dart';
import '../../views/settings/connection_configuration_view.dart';

import '../../globals.dart' as app;

class ConnectionsView extends StatefulWidget {
  const ConnectionsView({Key? key}) : super(key: key);

  @override
  _ConnectionsView createState() => _ConnectionsView();
}

class _ConnectionsView extends State<ConnectionsView> {
  _ConnectionsView() : super();

  Key selectedConfigurationKey = app.defaultConnectionConfiguration.key;
  List<ConnectionConfiguration> configurations = app.connectionConfigurations;

  Future<void> _goToConnectionConfigurationView({
    ConnectionConfiguration? configuration,
  }) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => ConnectionConfigurationView(
          configuration: configuration,
        ),
      ),
    );
    setState(() {
      configurations = app.connectionConfigurations;
      selectedConfigurationKey = app.defaultConnectionConfiguration.key;
    });
  }

  BorderSide get _listViewBorderSide => BorderSide(
        color: const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.lightBackgroundGray,
          darkColor: CupertinoColors.secondaryLabel,
        ).resolveFrom(context),
      );

  TextStyle get _listViewTextStyle => TextStyle(
        color: const CupertinoDynamicColor.withBrightness(
          color: CupertinoColors.black,
          darkColor: CupertinoColors.white,
        ).resolveFrom(context),
      );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
          ),
          onPressed: _goToConnectionConfigurationView,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView.builder(
          itemCount: configurations.length,
          itemBuilder: (BuildContext context, int index) {
            ConnectionConfiguration configuration = configurations[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: index == 0 ? _listViewBorderSide : BorderSide.none,
                  bottom: _listViewBorderSide,
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
                                configuration.key == selectedConfigurationKey,
                            onChanged: (state) {
                              setState(() {
                                configurations
                                    .firstWhere((element) =>
                                        element.key == selectedConfigurationKey)
                                    .isDefault = false;
                                selectedConfigurationKey = configuration.key;
                                configuration.isDefault = true;
                                app.connectionConfigurations = configurations;
                              });
                            },
                          ),
                          Text(
                            configuration.description,
                            style: _listViewTextStyle,
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      child: Icon(
                        CupertinoIcons.forward,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () => _goToConnectionConfigurationView(
                        configuration: configuration,
                      ),
                    ),
                  ],
                ),
                onDismissed: (DismissDirection direction) async {
                  configurations.remove(configuration);
                  app.connectionConfigurations = configurations;
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
                    setState(() {
                      configurations = app.connectionConfigurations;
                      selectedConfigurationKey =
                          app.defaultConnectionConfiguration.key;
                    });
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
