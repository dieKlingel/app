import 'dart:async';
import 'dart:convert';

import 'package:dieklingel_app/components/stream_subscription_mixin.dart';
import 'package:dieklingel_app/models/tunnel/tunnel.dart';
import 'package:rpc/rpc.dart';

class GetVersionResponse {
  final String version;

  GetVersionResponse(this.version);

  factory GetVersionResponse.fromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      throw Exception("the map has to be of type Map<String, dynamic>");
    }

    if (map["version"] is! String) {
      throw Exception("the key version is missing");
    }
    final String version = map["version"];

    return GetVersionResponse(version);
  }
}

class CoreRpcApi with StreamHandlerMixin {
  final Tunnel tunnel;
  final Map<String, Completer<Response?>> _request = {};

  CoreRpcApi(this.tunnel) {
    streams.subscribe(tunnel.messages, (event) {
      Response response = Response.fromMap(jsonDecode(event));
      _request[response.id]?.complete(response);
    });
  }

  Future<String?> getVersion() async {
    final req = Request("Core.GetVersion");
    final completer = Completer<Response?>();
    _request[req.id] = completer;
    tunnel.send(jsonEncode(req.toMap()));
    final res = await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );

    _request.remove(req.id);
    if (res == null) {
      return null;
    }

    res.throwIfError();
    return GetVersionResponse.fromMap(res.result).version;
  }

  Future<void> dispose() async {
    await streams.dispose();
  }
}
