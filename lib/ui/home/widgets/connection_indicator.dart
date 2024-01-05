import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';

class ConnectionIndicator extends StatelessWidget {
  final mqtt.ConnectionState controlConnectionState;

  const ConnectionIndicator({
    super.key,
    required this.controlConnectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Icon(controlConnectionState),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Headline(controlConnectionState),
                const SizedBox(height: 8.0),
                _Subtitle(controlConnectionState),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final mqtt.ConnectionState controlConnectionState;

  const _Icon(this.controlConnectionState);

  @override
  Widget build(BuildContext context) {
    switch (controlConnectionState) {
      case MqttConnectionState.disconnecting:
      case MqttConnectionState.disconnected:
      case MqttConnectionState.faulted:
        return const Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: CupertinoColors.activeOrange,
          size: 30,
        );
      case MqttConnectionState.connecting:
        return const Icon(
          CupertinoIcons.shield_lefthalf_fill,
          color: CupertinoColors.destructiveRed,
          size: 30,
        );
      case MqttConnectionState.connected:
        return const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: CupertinoColors.activeGreen,
          size: 30,
        );
    }
  }
}

class _Headline extends StatelessWidget {
  final mqtt.ConnectionState controlConnectionState;

  const _Headline(this.controlConnectionState);

  @override
  Widget build(BuildContext context) {
    switch (controlConnectionState) {
      case MqttConnectionState.disconnecting:
      case MqttConnectionState.disconnected:
      case MqttConnectionState.faulted:
        return const Text(
          "No Remote Access",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case MqttConnectionState.connecting:
        return const Text(
          "Connecting…",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case MqttConnectionState.connected:
        return const Text(
          "Remote Access",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }
}

class _Subtitle extends StatelessWidget {
  final mqtt.ConnectionState controlConnectionState;

  const _Subtitle(this.controlConnectionState);

  @override
  Widget build(BuildContext context) {
    switch (controlConnectionState) {
      case MqttConnectionState.disconnecting:
      case MqttConnectionState.disconnected:
      case MqttConnectionState.faulted:
        return Text(
          "Could not establish a connenction to the Control Server",
          style: Theme.of(context).textTheme.bodySmall,
        );
      case MqttConnectionState.connecting:
        return Text(
          "The connection establishment is still in progress",
          style: Theme.of(context).textTheme.bodySmall,
        );
      case MqttConnectionState.connected:
        return Text(
          "Succesfully connected to the Control Server",
          style: Theme.of(context).textTheme.bodySmall,
        );
    }
  }
}
