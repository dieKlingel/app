import 'package:dieklingel_app/states/home_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/home_repository.dart';

class HomeListViewBloc extends Bloc<HomeListEvent, HomeListState> {
  final HomeRepository homeRepository;

  HomeListViewBloc(this.homeRepository) : super(HomeListState()) {
    on<HomeListDeleted>(_onDeleted);
    on<HomeListRefresh>(_onRefresh);

    add(HomeListRefresh());
  }

  Future<void> _onDeleted(
    HomeListDeleted event,
    Emitter<HomeListState> emit,
  ) async {
    await homeRepository.delete(event.home);
    emit(HomeListState(homes: homeRepository.homes));
  }

  Future<void> _onRefresh(
    HomeListRefresh event,
    Emitter<HomeListState> emit,
  ) async {
    emit(HomeListState(homes: homeRepository.homes));
  }
}
