import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class PullDownMenuItemEmpty extends PullDownMenuEntry {
  const PullDownMenuItemEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  double get height => 0.0;

  @override
  bool get isDestructive => false;

  @override
  bool get represents => false;
}
