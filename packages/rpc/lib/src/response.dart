class Response {
  final String id;
  final Map<String, dynamic> result;
  final String? error;

  Response(
    this.id,
    this.result, {
    this.error,
  });

  factory Response.fromMap(dynamic map) {
    if (map is! Map<String, dynamic>) {
      throw Exception("could not parse the rpc response");
    }

    if (map["id"] is! String) {
      throw Exception("could not parse the rpc response; id is missing");
    }
    final String id = map["id"];

    if (map["result"] is! Map<String, dynamic>) {
      throw Exception("could not parse the rpc response; result is missing");
    }
    final Map<String, dynamic> result = map["result"];

    if (map["error"] is! String?) {
      throw Exception("could not parse the rpc response; result is missing");
    }
    final String? error = map["error"];

    return Response(
      id,
      result,
      error: error,
    );
  }

  void throwIfError() {
    final err = error;
    if (err == null) {
      return;
    }

    throw Exception(err);
  }
}
