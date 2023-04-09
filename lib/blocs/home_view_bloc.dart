import 'dart:async';

import 'package:dieklingel_app/models/hive_home.dart';
import 'package:dieklingel_app/repositories/home_repository.dart';
import 'package:dieklingel_app/states/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeViewBloc(this.homeRepository) : super(HomeState()) {
    on<HomeSelected>(_onSelected);
    on<HomeRefresh>(_onRefresh);

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
}
