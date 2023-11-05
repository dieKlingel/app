import 'package:dieklingel_app/models/device.dart';
import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/request.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mqtt/mqtt.dart';
import 'package:path/path.dart' as path;

class HomeAddViewBloc extends Bloc<HomeAddEvent, HomeAddState> {
  final HomeRepository homeRepository;

  HomeAddViewBloc(this.homeRepository) : super(HomeAddState()) {
    on<HomeAddSubmit>(_onSubmit);
  }

  Future<void> _onSubmit(
    HomeAddSubmit event,
    Emitter<HomeAddState> emit,
  ) async {
    String? nameError;
    if (event.name.isEmpty) {
      nameError = "Please enter a name";
    }

    String? serverError;
    /*RegExp serverRegex = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]+:\d{1,5}(\/?)$',
    );
    if (!serverRegex.hasMatch(event.server)) {
      serverError =
          "Please enter a server url within the format 'mqtt://server.org:1883/'";
    }*/

    String? channelError;
    RegExp channelRegex = RegExp(
      r'^\/?(([a-z])+([a-z.])+([a-z])+(\/?))+$',
    );
    if (!channelRegex.hasMatch(event.channel)) {
      channelError =
          "Please enter a channel prefix within format 'com.dieklingel/main/prefix/'";
    }

    HomeAddFormErrorState errorState = HomeAddFormErrorState(
      nameError: nameError,
      serverError: serverError,
      channelError: channelError,
    );
    if (errorState.hasError) {
      emit(errorState);
      return;
    }

    Uri url = Uri.parse(event.server);
    Uri uri = Uri.parse(
      "${url.scheme}://${url.authority}/${event.channel}#${event.sign}",
    );

    HiveHome home = event.home ?? HiveHome(name: event.name, uri: uri);
    home.name = event.name;
    home.uri = uri;
    home.username = event.username;
    home.password = event.password;
    home.passcode = event.passcode;

    emit(HomeAddLoadingState());
    final client = MqttClient(home.uri);
    try {
      await client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
      );
    } catch (e) {
      emit(
        HomeAddErrorState(
          "Could not conenct the the server ${uri.scheme}://${uri.host}:${uri.port} because ${e.toString()}",
        ),
      );
      return;
    }

    await homeRepository.add(home);
    await homeRepository.select(home);
    emit(HomeAddSuccessfulState());

    Box settingsBox = Hive.box("settings");
    String? token = settingsBox.get("token");

    if (token == null) {
      return;
    }

    await client.publish(
      path.normalize("./${home.uri.path}/devices/save"),
      Request.withJsonBody(
        "GET",
        Device(
          token,
          signs: [home.uri.fragment],
        ).toMap(),
      ).toJsonString(),
    );
    client.disconnect();
  }
}
