import 'package:dieklingel_app/extensions/mqtt_uri.dart';
import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/states/home_add_state.dart';
import 'package:dieklingel_core_shared/models/mqtt_uri.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    RegExp serverRegex = RegExp(
      r'^(mqtt|mqtts|ws|wss):\/\/(?:[A-Za-z0-9]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}(\/?)$',
    );
    if (!serverRegex.hasMatch(event.server)) {
      serverError =
          "Please enter a server url within the format 'mqtt://server.org:1883/'";
    }

    String? channelError;
    RegExp channelRegex = RegExp(
      r'^(([a-z]+)([a-z\.+])([a-z]+)\/)+$',
    );
    if (!channelRegex.hasMatch(event.channel)) {
      channelError =
          "Please enter a channel prefix within format 'com.dieklingel/main/prefix/'";
    }

    String? signError;
    RegExp signRegex = RegExp(
      r'^[A-Za-z]+$',
    );
    if (!signRegex.hasMatch(event.sign)) {
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

    Uri url = Uri.parse(event.server);
    MqttUri uri = MqttUri.fromUri(
      Uri.parse(
        "${url.scheme}://${url.authority}/${event.channel}#${event.sign}",
      ),
    );

    HiveHome home = event.home ?? HiveHome(name: event.name, uri: uri);
    home.name = event.name;
    home.uri = uri;
    home.username = event.username;
    home.password = event.password;

    homeRepository.add(home);

    emit(HomeAddSuccessfulState());
  }
}
