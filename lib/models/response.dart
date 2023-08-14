class Response {
  final String body;
  final Map<String, String> headers;
  final int statusCode;

  Response(
    this.statusCode,
    this.body, {
    this.headers = const {},
  });

  factory Response.fromMap(Map<String, dynamic> map) {
    String body = map["body"];
    Map<String, dynamic> headers = map["headers"];
    int statusCode = map["statusCode"];

    return Response(statusCode, body, headers: headers.cast());
  }

  Map<String, dynamic> toMap() {
    return {
      "statusCode": statusCode,
      "body": body,
      "headers": headers,
    };
  }
}
