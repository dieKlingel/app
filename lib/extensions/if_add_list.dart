extension IfAdd<E> on List<E> {
  List<E> ifAdd(E item, {bool condition = true}) {
    if (condition) {
      add(item);
    }
    return this;
  }

  List<E> ifNull(dynamic object, E item) {
    if (object == null) {
      add(item);
    }
    return this;
  }

  List<E> ifNotNull(dynamic object, E item) {
    if (object != null) {
      add(item);
    }
    return this;
  }

  List<E> forAdd(List<E> item) {
    addAll(item);
    return this;
  }
}
