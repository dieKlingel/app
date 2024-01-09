import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum TunnelState {
  disconnected,
  connecting,
  relayed,
  connected;

  static TunnelState from({
    mqtt.Client? control,
    RTCPeerConnection? peer,
  }) {
    if (peer == null && control == null) {
      return TunnelState.disconnected;
    }

    if (peer != null) {
      switch (peer.connectionState) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          return TunnelState.connected;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          return TunnelState.connecting;
        default:
          break;
      }
    }

    if (control != null) {
      switch (control.state) {
        case mqtt.ConnectionState.connected:
          return TunnelState.relayed;
        case mqtt.ConnectionState.connecting:
          return TunnelState.connecting;
        default:
          break;
      }
    }

    return TunnelState.disconnected;
  }
}
