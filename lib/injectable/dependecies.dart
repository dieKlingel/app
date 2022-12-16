import 'package:dieklingel_app/injectable/dependecies.config.dart';
import 'package:dieklingel_app/messaging/mclient.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit()
void configureDependecies() {
  GetIt.I.registerFactory(() => MClient());
  GetIt.I.init();
}
