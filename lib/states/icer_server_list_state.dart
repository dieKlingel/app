import '../models/hive_ice_server.dart';

class IceServerListState {
  final List<HiveIceServer> servers;

  IceServerListState({this.servers = const []});
}

class IceServerListEvent {}

class IceServerListRefresh extends IceServerListEvent {}

class IceServerListDeleted extends IceServerListEvent {
  final HiveIceServer server;

  IceServerListDeleted({required this.server});
}
