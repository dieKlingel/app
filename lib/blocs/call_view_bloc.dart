import 'dart:async';

import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:rxdart/rxdart.dart';

abstract class CallState {}

class ConnectedCallState extends CallState {}

class DisconnectedCallState extends CallState {}

class UnavailableCallState extends CallState {}

abstract class MicState {}

class EnabledMicState extends MicState {}

class DisablesMicState extends MicState {}

class CallViewBloc extends Bloc {
  @override
  void dispose() {
    // TODO: implement dispose
  }
}
