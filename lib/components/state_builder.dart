import 'package:dieklingel_app/event/event_emitter.dart';

class StateBuilder extends EventEmitter {
  void rebuild() {
    emit("rebuild", {});
  }
}
