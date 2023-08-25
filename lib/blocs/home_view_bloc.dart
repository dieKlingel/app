import 'dart:async';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/models/request.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/states/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt/mqtt.dart';
import 'package:path/path.dart' as path;

class HomeViewBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeViewBloc(this.homeRepository) : super(HomeState()) {
    on<HomeSelected>(_onSelected);
    on<HomeRefresh>(_onRefresh);
    on<HomeUnlock>(_onUnlock);

    add(HomeRefresh());
  }

  Future<void> _onSelected(HomeSelected event, Emitter<HomeState> emit) async {
    await homeRepository.select(event.home);
    emit(
      HomeSelectedState(home: event.home, homes: homeRepository.homes),
    );
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    HiveHome? selected = homeRepository.selected;
    if (selected == null && homeRepository.homes.isNotEmpty) {
      await homeRepository.select(homeRepository.homes.first);
      selected = homeRepository.selected;
    }

    if (selected == null) {
      emit(HomeState(
        homes: homeRepository.homes,
      ));
    } else {
      emit(
        HomeSelectedState(home: selected, homes: homeRepository.homes),
      );
    }
  }

  Future<void> _onUnlock(HomeUnlock event, Emitter<HomeState> emit) async {
    HiveHome? home = homeRepository.selected;
    if (home == null) {
      return;
    }

    MqttClient client = MqttClient(home.uri);
    try {
      await client.connect(
        username: home.username ?? "",
        password: home.password ?? "",
      );
    } catch (e) {
      print("error ${e.toString()}");
      return;
    }

    await client.publish(
        path.normalize("./${home.uri.path}/actions/execute"),
        Request.withJsonBody("GET", {
          "pattern": "unlock",
          "environment": {
            "PASSCODE": home.passcode,
          }
        }).toJsonString());
  }
}
