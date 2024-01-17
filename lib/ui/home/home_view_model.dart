import 'package:dieklingel_app/components/stream_subscription_mixin.dart';
import 'package:dieklingel_app/models/core/core_rpc_api.dart';
import 'package:dieklingel_app/models/home.dart';
import 'package:dieklingel_app/models/tunnel/tunnel.dart';
import 'package:dieklingel_app/models/tunnel/tunnel_state.dart';

import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomeViewModel extends ChangeNotifier with StreamHandlerMixin {
  final HomeRepository homeRepository;
  final RTCVideoRenderer renderer = RTCVideoRenderer();

  Home? _home;
  Tunnel? _tunnel;
  CoreRpcApi? _core;
  String version = "";

  HomeViewModel(this.homeRepository) {
    streams.subscribe(homeRepository.added, (home) => notifyListeners());
    streams.subscribe(homeRepository.changed, (home) {
      notifyListeners();
      if (home.$1.id != _home?.id) {
        return;
      }

      disconnect();
      this.home = home.$2;
      connect();
    });
    streams.subscribe(homeRepository.removed, (home) => notifyListeners());

    _home = homeRepository.homes.firstOrNull;
    connect();
  }

  set home(Home? home) {
    _home = home;
    notifyListeners();
  }

  Home? get home {
    return _home;
  }

  List<Home> get homes {
    return homeRepository.homes;
  }

  TunnelState get state {
    return _tunnel?.state ?? TunnelState.disconnected;
  }

  Future<void> connect() async {
    final home = _home;
    if (home == null) {
      return;
    }

    await _tunnel?.dispose();
    await _core?.dispose();
    final tunnel = Tunnel(
      home.uri,
      username: home.username ?? "",
      password: home.password ?? "",
    );
    _tunnel = tunnel;
    _core = CoreRpcApi(tunnel);

    tunnel.onStateChanged = (_) async {
      final core = _core;
      if (core == null) {
        return;
      }

      if (state == TunnelState.relayed || state == TunnelState.connected) {
        final v = await core.getVersion();
        version = "Version: $v";

        // TODO: set the fcm token
        // await core.setFcmToken(tunnel.username, "");
      }
      notifyListeners();
    };

    tunnel.onVideoTrackReceived = (stream) async {
      renderer.srcObject = stream;
    };

    await renderer.initialize();
    await tunnel.connect();
  }

  Future<void> disconnect() async {
    final tunnel = _tunnel;
    final home = _home;
    if (tunnel == null || home == null) {
      return;
    }

    await tunnel.disconnect();
  }

  void reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(milliseconds: 100));
    await connect();
  }

  @override
  void dispose() {
    _core?.dispose();
    streams.dispose();
    super.dispose();
  }
}
