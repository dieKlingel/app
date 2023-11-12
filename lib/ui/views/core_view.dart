import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/ui/view_models/call_view_model.dart';
import 'package:dieklingel_app/ui/view_models/core_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart';
import 'package:provider/provider.dart';

import 'call_view.dart';

class CoreView extends StatelessWidget {
  const CoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionErrorMessage = context.select<CoreViewModel, String?>(
      (value) => value.connectionErrorMessage,
    );
    if (connectionErrorMessage != null) {
      return Center(
        child: Text(connectionErrorMessage),
      );
    }

    final isConnected = context.select<CoreViewModel, bool>(
      (value) => value.isConnected,
    );
    if (!isConnected) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    final client = context.select<CoreViewModel, Client>(
      (value) => value.client,
    );
    final home = context.select<CoreViewModel, HiveHome>(
      (value) => value.home,
    );

    return ChangeNotifierProvider(
      create: (_) => CallViewModel(
        home,
        client,
        context.read<IceServerRepository>(),
      ),
      child: const CallView(),
    );
  }
}
