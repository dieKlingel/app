import 'package:dieklingel_app/models/tunnel/tunnel_state.dart';
import 'package:flutter/cupertino.dart';

class ConnectionIndicator extends StatelessWidget {
  final TunnelState state;

  const ConnectionIndicator({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Icon(state),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Headline(state),
                const SizedBox(height: 8.0),
                _Subtitle(state),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final TunnelState state;

  const _Icon(this.state);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TunnelState.disconnected:
        return const Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: CupertinoColors.activeOrange,
          size: 30,
        );
      case TunnelState.connecting:
        return const Icon(
          CupertinoIcons.shield_lefthalf_fill,
          color: CupertinoColors.destructiveRed,
          size: 30,
        );
      case TunnelState.relayed:
        return const Icon(
          CupertinoIcons.shield_lefthalf_fill,
          color: CupertinoColors.systemOrange,
          size: 30,
        );

      case TunnelState.connected:
        return const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: CupertinoColors.activeGreen,
          size: 30,
        );
    }
  }
}

class _Headline extends StatelessWidget {
  final TunnelState state;

  const _Headline(this.state);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TunnelState.disconnected:
        return const Text(
          "No Remote Access",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case TunnelState.connecting:
        return const Text(
          "Connecting…",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case TunnelState.relayed:
        return const Text(
          "Partial Remote Access",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case TunnelState.connected:
        return const Text(
          "Remote Access",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }
}

class _Subtitle extends StatelessWidget {
  final TunnelState state;

  const _Subtitle(this.state);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TunnelState.disconnected:
        return Text(
          "Could not establish a connenction to the Control Server",
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        );
      case TunnelState.connecting:
        return Text(
          "The connection establishment is still in progress",
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        );
      case TunnelState.relayed:
        return Text(
          "The connection is relayed by a Control Server",
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        );
      case TunnelState.connected:
        return Text(
          "Succesfully connected",
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
        );
    }
  }
}
