import 'package:dieklingel_app/ui/home/call/call_view_model.dart';

import '../call/call_view.dart';
import 'package:dieklingel_app/ui/home/home_view_model.dart';
import 'package:dieklingel_app/ui/home/widgets/connection_indicator.dart';
import 'package:dieklingel_app/ui/home/widgets/viedeo_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../models/home.dart';

class HomeBody extends StatelessWidget {
  final Home home;

  const HomeBody({
    super.key,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((HomeViewModel vm) => vm.state);
    final renderer = context.select((HomeViewModel vm) => vm.renderer);
    final version = context.select((HomeViewModel vm) => vm.version);

    return SafeArea(
      child: ListView(
        children: [
          ConnectionIndicator(
            state: state,
          ),
          VideoView(
            renderer,
            onTap: () async {
              final vm = context.read<HomeViewModel>();
              final connection = vm.connection;
              if (connection == null) {
                return;
              }
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => CallViewModel(
                      renderer: renderer,
                      connection: connection,
                    ),
                    child: const CallView(),
                  ),
                ),
              );
            },
          ),
          Text(
            version,
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
