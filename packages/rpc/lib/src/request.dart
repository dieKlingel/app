import 'package:uuid/uuid.dart';

class Request {
  final String version = "1.0";
  final String method;
  final String id;
  final List<Map<String, dynamic>> params;

  Request(
    this.method, {
    String? id,
    this.params = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      "jsonrpc": version,
      "method": method,
      "id": id,
      "params": params,
    };
  }
}
