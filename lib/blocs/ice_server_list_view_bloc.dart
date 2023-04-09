import 'dart:async';

import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/icer_server_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IceServerListViewBloc
    extends Bloc<IceServerListEvent, IceServerListState> {
  final IceServerRepository iceServerRepository;

  IceServerListViewBloc(this.iceServerRepository)
      : super(IceServerListState()) {
    on<IceServerListRefresh>(_onRefresh);
    on<IceServerListDeleted>(_onDeleted);

    add(IceServerListRefresh());
  }

  Future<void> _onDeleted(
    IceServerListDeleted event,
    Emitter<IceServerListState> emit,
  ) async {
    await iceServerRepository.delete(event.server);
    emit(IceServerListState(servers: iceServerRepository.servers));
  }

  Future<void> _onRefresh(
    IceServerListRefresh event,
    Emitter<IceServerListState> emit,
  ) async {
    emit(IceServerListState(servers: iceServerRepository.servers));
  }
}
