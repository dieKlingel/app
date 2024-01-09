import 'package:dieklingel_app/ui/home/home_view_model.dart';
import 'package:dieklingel_app/ui/home/widgets/connection_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

    return SafeArea(
      child: ListView(
        children: [
          ConnectionIndicator(
            state: state,
          ),
        ],
      ),
    );
  }
}
