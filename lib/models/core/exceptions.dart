class RpcTimeoutException implements Exception {
  final String method;

  RpcTimeoutException(this.method);

  @override
  String toString() {
    return "RPC: $method; did not receive a response for the method";
  }
}
