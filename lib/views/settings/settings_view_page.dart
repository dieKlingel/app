import 'package:flutter/cupertino.dart';

import '../../components/ice_configuration.dart';
import '../../views/settings/connections_view.dart';
import '../../views/settings/ice_view.dart';
import '../../components/connection_configuration.dart';
import 'connection_configuration_view.dart';
import 'ice_configuration_view_page.dart';

class SettingsViewPage extends StatefulWidget {
  const SettingsViewPage({Key? key}) : super(key: key);

  @override
  State<SettingsViewPage> createState() => _SettingsViewPage();
}

enum ContentView {
  connetionsView,
  iceView,
}

class _SettingsViewPage extends State<SettingsViewPage> {
  late final Map<ContentView, Widget> contentViews = {
    ContentView.connetionsView: const ConnectionsView(),
    ContentView.iceView: const IceView(),
  };
  ContentView _selectedSegment = ContentView.connetionsView;

  Future<void> _goToConnectionConfigurationView(
    BuildContext context, {
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
  }

  Future<void> _goToIceConfiurationViewPage(
    BuildContext context, {
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

  Widget? get navBarTrailingButton {
    Widget? button;
    switch (_selectedSegment) {
      case ContentView.connetionsView:
        button = CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
          ),
          onPressed: () => _goToConnectionConfigurationView(context),
        );
        break;
      case ContentView.iceView:
        button = CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
          ),
          onPressed: () => _goToIceConfiurationViewPage(context),
        );
        break;
      default:
        break;
    }
    return button;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("dieKlingel"),
        trailing: navBarTrailingButton,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: CupertinoSlidingSegmentedControl(
                groupValue: _selectedSegment,
                onValueChanged: (ContentView? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedSegment = value;
                  });
                },
                children: const <ContentView, Widget>{
                  ContentView.connetionsView: Text("Connections"),
                  ContentView.iceView: Text("ICE"),
                },
              ),
            ),
            Expanded(
              child: contentViews[_selectedSegment]!,
            )
          ],
        ),
      ),
    );
  }
}
