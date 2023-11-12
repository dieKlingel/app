import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart' as mqtt;

import '../../models/home.dart';

class OutgoingCallViewModel extends ChangeNotifier {
  final Home home;
  final mqtt.Client connection;

  OutgoingCallViewModel({required this.home, required this.connection});
}
