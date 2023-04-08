import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:dieklingel_core_shared/models/mqtt_uri.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeAddViewBloc extends Bloc<HomeAddEvent, HomeAddState> {
  final HomeRepository homeRepository;

  String _name = "";
  String _server = "";
  String _username = "";
  String _password = "";
  String _channel = "";
  String _sign = "";

  HomeAddViewBloc(this.homeRepository) : super(HomeAddState()) {
    on<HomeAddName>(_onAddName);
    on<HomeAddServer>(_onAddServer);
    on<HomeAddUsername>(_onAddUsername);
    on<HomeAddPassword>(_onAddPassword);
    on<HomeAddChannel>(_onAddChannel);
    on<HomeAddSign>(_onAddSign);
    on<HomeAddSubmit>(_onSubmit);
  }

  Future<void> _onAddName(HomeAddName event, Emitter<HomeAddState> emit) async {
    _name = event.name;
  }

  Future<void> _onAddServer(
    HomeAddServer event,
    Emitter<HomeAddState> emit,
  ) async {
    _server = event.server;
  }

  Future<void> _onAddUsername(
    HomeAddUsername event,
    Emitter<HomeAddState> emit,
  ) async {
    _username = event.username;
  }

  Future<void> _onAddPassword(
    HomeAddPassword event,
    Emitter<HomeAddState> emit,
  ) async {
    _password = event.password;
  }

  Future<void> _onAddChannel(
    HomeAddChannel event,
    Emitter<HomeAddState> emit,
  ) async {
    _channel = event.channel;
  }

  Future<void> _onAddSign(HomeAddSign event, Emitter<HomeAddState> emit) async {
    _sign = event.sign;
  }

  Future<void> _onSubmit(
    HomeAddSubmit event,
    Emitter<HomeAddState> emit,
  ) async {
    String? nameError;
    if (_name.isEmpty) {
      nameError = "Please enter a name";
    }

    String? serverError;
    RegExp serverRegex = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
    );
    if (!serverRegex.hasMatch(_server)) {
      serverError =
          "Please enter a server url within the format 'mqtt://server.org:1883/'";
    }

    String? channelError;
    RegExp channelRegex = RegExp(
      r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
    );
    if (!channelRegex.hasMatch(_channel)) {
      channelError =
          "Please enter a channel prefix within format 'com.dieklingel/main/prefix/'";
    }

    String? signError;
    RegExp signRegex = RegExp(
      r'^[A-Za-z]+$',
    );
    if (!signRegex.hasMatch(_sign)) {
      signError = "Please enter a sign within the format 'mysign'";
    }

    HomeAddFormErrorState errorState = HomeAddFormErrorState(
      nameError: nameError,
      serverError: serverError,
      channelError: channelError,
      signError: signError,
    );
    if (errorState.hasError) {
      emit(errorState);
      return;
    }

    Uri url = Uri.parse(_server);
    MqttUri uri = MqttUri.fromUri(
      Uri.parse(
        "${url.scheme}://${url.authority}/$_channel#$_sign",
      ),
    );

    HiveHome home = event.home ?? HiveHome(name: _name, uri: uri);
    home.name = _name;
    home.uri = uri;
    home.username = _username;
    home.password = _password;

    homeRepository.add(home);

    emit(HomeAddSuccessfulState());
  }
}
