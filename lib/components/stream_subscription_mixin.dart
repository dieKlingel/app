import 'dart:async';

class StreamHandler {
  final List<StreamSubscription> _subscriptions = [];

  void subscribe<T>(Stream<T> stream, void Function(T) handler) {
    _subscriptions.add(stream.listen(handler));
  }

  Future<void> dispose() async {
    await Future.wait(
      _subscriptions.map(
        (sub) => sub.cancel(),
      ),
    );
    _subscriptions.clear();
  }
}

mixin StreamHandlerMixin {
  final StreamHandler streams = StreamHandler();
}
