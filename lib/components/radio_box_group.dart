import 'package:dieklingel_app/components/radio_box.dart';
import 'package:flutter/material.dart';

class RadioBoxGroup {
  int maxSelection;
  List<RadioBox> _radioBoxes = List<RadioBox>.empty(growable: true);

  RadioBoxGroup({required this.maxSelection});

  void append(RadioBox radioBox) {
    _radioBoxes.add(radioBox);
  }
}
