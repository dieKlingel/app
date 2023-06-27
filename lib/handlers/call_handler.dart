import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class CallHandler {
  final Uri uri;
  final String uuid;
  final String? username;
  final String? password;
  final Router handler = Router();

  CallHandler(
    this.uri, {
    required this.uuid,
    this.username,
    this.password,
  }) {
    handler.connect("/rtc/connections/$uuid", (Request request) {});
  }
}
