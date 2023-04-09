import '../models/hive_home.dart';

class HomeListState {
  final List<HiveHome> homes;

  HomeListState({this.homes = const []});
}

class HomeListEvent {}

class HomeListRefresh extends HomeListEvent {}

class HomeListDeleted extends HomeListEvent {
  final HiveHome home;

  HomeListDeleted({required this.home});
}
