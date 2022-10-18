import 'dart:async';

import 'package:dieklingel_app/database/objectdb_factory.dart';
import 'package:dieklingel_app/views/settings/connections_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:objectdb/objectdb.dart';

import '../../components/ice_server.dart';
import 'ice_servers_view.dart';
import '../../components/connection_configuration.dart';
import 'connection_configuration_view.dart';
import 'ice_server_config_view_page.dart';

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
  final StreamController<IceServer> _iceServers =
      StreamController<IceServer>.broadcast();

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
    IceServer? configuration,
  }) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => IceServerConfigViewPage(
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
          onPressed: () async {
            IceServer? server = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) =>
                    const IceServerConfigViewPage(),
              ),
            );
            if (null == server) return;
            _iceServers.add(server);
          },
        );
        break;
      default:
        break;
    }
    return button;
  }

  Widget _content() {
    switch (_selectedSegment) {
      case ContentView.connetionsView:
        return const ConnectionsView();
      case ContentView.iceView:
        return IceServersView(
          insert: _iceServers.stream,
        );
    }
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
            Expanded(child: _content())
          ],
        ),
      ),
    );
  }
}
