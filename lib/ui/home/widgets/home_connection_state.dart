import 'package:flutter/cupertino.dart';
import 'package:mqtt/mqtt.dart' as mqtt;

class HomeConnectionState extends StatelessWidget {
  final mqtt.ConnectionState state;

  const HomeConnectionState(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String message;

    switch (state) {
      case mqtt.ConnectionState.connected:
        icon = CupertinoIcons.check_mark_circled;
        message = "Connected";
        break;
      case mqtt.ConnectionState.connecting:
        icon = CupertinoIcons.refresh_circled;
        message = "Connecting...";
        break;
      case mqtt.ConnectionState.disconnected:
        icon = CupertinoIcons.xmark_circle;
        message = "Disconnected";
        break;
      case mqtt.ConnectionState.disconnecting:
        icon = CupertinoIcons.xmark_circle;
        message = "Disconnecting...";
        break;
      case mqtt.ConnectionState.faulted:
        icon = CupertinoIcons.xmark_circle;
        message = "Connection-Error";
        break;
    }

    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(message),
      ],
    );
  }
}
