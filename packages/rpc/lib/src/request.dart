import 'package:rpc/src/rpc_map.dart';
import 'package:uuid/uuid.dart';

class Request {
  final String version = "1.0";
  final String method;
  final String id;
  final List<RpcMap> params;

  Request(
    this.method, {
    String? id,
    this.params = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    final List<dynamic> params = this.params.map((e) => e.toMap()).toList();

    return {
      "jsonrpc": version,
      "method": method,
      "id": id,
      "params": params,
    };
  }
}
