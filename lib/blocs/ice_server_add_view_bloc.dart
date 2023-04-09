import 'package:dieklingel_app/models/hive_ice_server.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/states/icer_server_add_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IceServerAddViewBloc extends Bloc<IceServerAddEvent, IceServerAddState> {
  final IceServerRepository iceServerRepository;

  IceServerAddViewBloc(this.iceServerRepository) : super(IceServerAddState()) {
    on<IceServerAddSubmit>(_onSubmit);
  }

  Future<void> _onSubmit(
    IceServerAddSubmit event,
    Emitter<IceServerAddState> emit,
  ) async {
    String? urlsError;
    RegExp urlsRegex = RegExp(
      r'(stun|turn):(?:[A-Za-z0-9-]+\.)+[A-Za-z0-9]{2,3}:\d{1,5}$',
    );
    if (!urlsRegex.hasMatch(event.urls)) {
      urlsError =
          "Please enter a url within the format: 'stun:example.com:19302' or 'turn:example.com:19203";
    }

    IceServerAddFormErrorState errorState = IceServerAddFormErrorState(
      urlsError: urlsError,
    );
    if (errorState.hasError) {
      emit(errorState);
      return;
    }

    HiveIceServer server = event.server ?? HiveIceServer(urls: event.urls);
    server.urls = event.urls;
    server.username = event.username;
    server.credential = event.credential;

    await iceServerRepository.add(server);
    emit(IceServerAddSuccessfulState());
  }
}
