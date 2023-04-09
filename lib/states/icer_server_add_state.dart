import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/hive_ice_server.dart';

class IceServerAddState {}

class IceServerAddFormErrorState extends IceServerAddState {
  final String? urlsError;
  final String? usernameError;
  final String? credentialError;

  bool get hasError {
    return urlsError != null ||
        usernameError != null ||
        credentialError != null;
  }

  IceServerAddFormErrorState({
    this.urlsError,
    this.usernameError,
    this.credentialError,
  });
}

class IceServerAddSuccessfulState extends IceServerAddState {}

class IceServerAddEvent {}

class IceServerAddSubmit extends IceServerAddEvent {
  final HiveIceServer? server;
  final String urls;
  final String username;
  final String credential;

  IceServerAddSubmit({
    required this.server,
    required this.urls,
    required this.username,
    required this.credential,
  });
}
