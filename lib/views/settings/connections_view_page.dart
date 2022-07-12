import 'package:flutter/cupertino.dart';

import '../../components/connection_configuration.dart';
import 'connection_configuration_view.dart';

class ConnectionsViewPage extends StatelessWidget {
  const ConnectionsViewPage({Key? key}) : super(key: key);

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
          onPressed: () => _goToConnectionConfigurationView(context),
        ),
      ),
      child: const SafeArea(
        bottom: false,
        child: Text("hh"),
      ),
    );
  }
}
