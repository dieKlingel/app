import '../models/hive_home.dart';

class HomeState {
  final List<HiveHome> homes;

  HomeState({this.homes = const []});
}

class HomeSelectedState extends HomeState {
  final HiveHome home;

  HomeSelectedState({required this.home, super.homes});
}

class HomeEvent {}

class HomeSelected extends HomeEvent {
  final HiveHome home;

  HomeSelected({required this.home});
}

class HomeRefresh extends HomeEvent {}

class HomeUnlock extends HomeEvent {}
