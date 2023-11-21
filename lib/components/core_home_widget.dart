import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';

import '../models/home.dart';

class CoreHomeWidget extends StatefulWidget {
  final Home home;
  final mqtt.Client client;
  final Function? onCallPressed;
  final Function? onUnlockPressed;

  const CoreHomeWidget({
    super.key,
    required this.home,
    required this.client,
    this.onCallPressed,
    this.onUnlockPressed,
  });

  @override
  State<CoreHomeWidget> createState() => _CoreHomeWidgetState();
}

class _CoreHomeWidgetState extends State<CoreHomeWidget> {
  mqtt.ConnectionState _connectionState = MqttConnectionState.faulted;

  @override
  void initState() {
    widget.client.onConnectionStateChanged = (state) {
      setState(() {
        _connectionState = state;
      });
    };

    _connectionState = widget.client.state;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.tertiarySystemGroupedBackground,
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.home.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.client.connect(
                    username: widget.home.username ?? "",
                    password: widget.home.password ?? "",
                  );
                },
                child: const Icon(
                  CupertinoIcons.restart,
                  size: 20,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _ConnectionState(_connectionState),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                color: Colors.green,
                onPressed: _connectionState == mqtt.ConnectionState.connected
                    ? () => widget.onCallPressed?.call()
                    : null,
                child: const Icon(
                  CupertinoIcons.phone_fill,
                ),
              ),
              const SizedBox(width: 6.0),
              const CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                color: Colors.amber,
                onPressed: null,
                // TODO: enable unlock
                /*_connectionState == mqtt.ConnectionState.connected
                    ? () => widget.onUnlockPressed?.call()
                    : null,*/
                child: Icon(
                  CupertinoIcons.lock_fill,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ConnectionState extends StatelessWidget {
  final mqtt.ConnectionState state;

  const _ConnectionState(this.state);

  @override
  Widget build(BuildContext context) {
    String message;
    switch (state) {
      case mqtt.ConnectionState.disconnected:
        message = "disconnected";
        break;
      case mqtt.ConnectionState.connecting:
        message = "connecting";
        break;
      case mqtt.ConnectionState.connected:
        message = "connected";
        break;
      case mqtt.ConnectionState.disconnecting:
        message = "disconnecting";
        break;
      case mqtt.ConnectionState.faulted:
        message = "could not connect";
        break;
    }

    return Text(
      message,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}
