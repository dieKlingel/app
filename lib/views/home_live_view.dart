import 'package:dieklingel_app/view_models/home_live_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../models/home.dart';

class HomeLiveView extends StatefulWidget {
  final Home home;

  const HomeLiveView({required this.home, super.key});

  @override
  State<StatefulWidget> createState() => _HomeLiveView();
}

class _HomeLiveView extends State<HomeLiveView> {
  final HomeLiveViewModel _vm = GetIt.I.get<HomeLiveViewModel>();
  late final Home _home = widget.home;

  @override
  void initState() {
    // _vm.connect(_home);
    super.initState();
  }

  Widget _header(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(_home.name),
    );
  }

  Widget _body(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text("a"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _vm,
      builder: (context, child) => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: [
            _header(context),
            _body(context),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _vm.disconnect(_home);
    super.dispose();
  }
}
