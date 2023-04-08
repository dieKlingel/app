import 'package:dieklingel_app/models/hive_home.dart';

class HomeAddState {}

class HomeAddFormErrorState extends HomeAddState {
  final String? nameError;
  final String? serverError;
  final String? channelError;
  final String? signError;

  bool get hasError {
    return nameError != null ||
        serverError != null ||
        channelError != null ||
        signError != null;
  }

  HomeAddFormErrorState({
    this.nameError,
    this.serverError,
    this.channelError,
    this.signError,
  });
}

class HomeAddSuccessfulState extends HomeAddState {}

class HomeAddEvent {}

class HomeAdd extends HomeAddEvent {
  final HiveHome home;

  HomeAdd({required this.home});
}

class HomeAddName extends HomeAddEvent {
  final String name;

  HomeAddName({required this.name});
}

class HomeAddServer extends HomeAddEvent {
  final String server;

  HomeAddServer({required this.server});
}

class HomeAddUsername extends HomeAddEvent {
  final String username;

  HomeAddUsername({required this.username});
}

class HomeAddPassword extends HomeAddEvent {
  final String password;

  HomeAddPassword({required this.password});
}

class HomeAddChannel extends HomeAddEvent {
  final String channel;

  HomeAddChannel({required this.channel});
}

class HomeAddSign extends HomeAddEvent {
  final String sign;

  HomeAddSign({required this.sign});
}

class HomeAddSubmit extends HomeAddEvent {
  HiveHome? home;

  HomeAddSubmit({this.home});
}
