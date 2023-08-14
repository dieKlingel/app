import 'dart:convert';

class Request {
  final String body;
  final String method;
  final Map<String, String> headers;

  Request(this.method, this.body, {this.headers = const {}});

  factory Request.fromMap(Map<String, dynamic> map) {
    String body = map["body"];
    String method = map["method"];
    Map<String, dynamic> headers = map["headers"];

    return Request(method, body, headers: headers.cast());
  }

  factory Request.withJsonBody(
    String method,
    Map<String, dynamic> body, {
    Map<String, String> headers = const {},
  }) {
    String json = jsonEncode(body);
    return Request(method, json, headers: headers);
  }

  Request withAnswerChannel(String topic) {
    Map<String, String> header = {};
    header.addAll(headers);
    header["mqtt_answer_channel"] = topic;

    return Request(method, body, headers: header);
  }

  Map<String, dynamic> toMap() {
    return {
      "method": method,
      "body": body,
      "headers": headers,
    };
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }
}
