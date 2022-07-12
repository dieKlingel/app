import 'package:dieklingel_app/components/state_builder.dart';
import 'package:dieklingel_app/views/settings/connections_view.dart';
import 'package:flutter/cupertino.dart';

import '../../components/connection_configuration.dart';
import 'connection_configuration_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsView createState() => _SettingsView();
}

enum ContentView {
  connetionsView,
  iceView,
  generalView,
}

class _SettingsView extends State<SettingsView> {
  final StateBuilder _connectionsViewDataBuilder = StateBuilder();
  late final Map<ContentView, Widget> contentViews = {
    ContentView.connetionsView: ConnectionsView(
      dataBuilder: _connectionsViewDataBuilder,
    ),
    ContentView.iceView: const Text("wortk in progress"),
    ContentView.generalView: const Text("working"),
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
    _connectionsViewDataBuilder.rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoSlidingSegmentedControl(
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
            ContentView.generalView: Text("General"),
          },
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.add,
          ),
          onPressed: () => _goToConnectionConfigurationView(context),
        ),
      ),
      child: SafeArea(
        child: contentViews[_selectedSegment]!,
      ),
    );
  }
}
