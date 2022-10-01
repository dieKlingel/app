import '../../components/app_settings.dart';
import 'package:provider/provider.dart';

import '../settings/ice_configuration_view_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/ice_configuration.dart';

class IceView extends StatefulWidget {
  const IceView({Key? key}) : super(key: key);

  @override
  State<IceView> createState() => _IceView();
}

class _IceView extends State<IceView> {
  _IceView() : super();

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
    return ListView.builder(
      itemCount: context.watch<AppSettings>().iceConfigurations.length,
      itemBuilder: (BuildContext context, int index) {
        IceConfiguration configuration =
            context.watch<AppSettings>().iceConfigurations[index];
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
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 00, 22),
                    child: Text(
                      configuration.urls,
                      overflow: TextOverflow.ellipsis,
                      style: _listViewTextStyle,
                    ),
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
            confirmDismiss: (direction) async =>
                context.read<AppSettings>().iceConfigurations.length > 1,
            onDismissed: (DismissDirection direction) async {
              context
                  .read<AppSettings>()
                  .iceConfigurations
                  .remove(configuration);
            },
          ),
        );
      },
    );
  }
}
