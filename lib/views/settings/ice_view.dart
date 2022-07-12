import 'package:dieklingel_app/components/state_builder.dart';
import 'package:dieklingel_app/views/settings/ice_configuration_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/ice_configuration.dart';
import '../../globals.dart' as app;

class IceView extends StatefulWidget {
  const IceView({this.stateBuilder, Key? key}) : super(key: key);
  final StateBuilder? stateBuilder;

  @override
  _IceView createState() => _IceView();
}

class _IceView extends State<IceView> {
  _IceView() : super();

  List<IceConfiguration> configurations = app.iceConfigurations;

  Future<void> _goToIceConfigurationViewPage({
    IceConfiguration? configuration,
  }) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => IceConfigurationViewPage(
          configuration: configuration,
        ),
      ),
    );
    setState(() {
      configurations = app.iceConfigurations;
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

  void rebuild(dynamic data) {
    setState(() {
      configurations = app.iceConfigurations;
    });
  }

  @override
  void initState() {
    widget.stateBuilder?.addEventListener("rebuild", rebuild);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: configurations.length,
      itemBuilder: (BuildContext context, int index) {
        IceConfiguration configuration = configurations[index];
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
                  padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Row(
                    children: [
                      Text(
                        configuration.urls,
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
                  onPressed: () => _goToIceConfigurationViewPage(
                    configuration: configuration,
                  ),
                ),
              ],
            ),
            confirmDismiss: (direction) async => configurations.length > 1,
            onDismissed: (DismissDirection direction) async {
              configurations.remove(configuration);
              app.iceConfigurations = configurations;
              //if (configurations.isEmpty) {
              /*Navigator.popUntil(context, (route) {
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
                });*/
              //} else {
              setState(() {
                configurations = app.iceConfigurations;
              });
              //}
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.stateBuilder?.removeEventListener("rebuild", rebuild);
  }
}
