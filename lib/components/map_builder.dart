class MapBuilder<T_ID, T_VALUE> {
  final T_ID? id;
  final Map<T_ID, T_VALUE> values;
  final T_VALUE? fallback;

  MapBuilder({this.id, this.fallback, this.values = const {}});

  MapBuilder<T_ID, T_VALUE> withValues(Map<T_ID, T_VALUE> map) {
    return MapBuilder(id: id, values: map, fallback: fallback);
  }

  MapBuilder<T_ID, T_VALUE> withFallback(T_VALUE fallback) {
    return MapBuilder(id: id, values: values, fallback: fallback);
  }

  MapBuilder<T_ID, T_VALUE> from(T_ID? id) {
    return MapBuilder(id: id, values: values, fallback: fallback);
  }

  T_VALUE build() {
    if (id == null && fallback == null) {
      throw BuilderException("cannot build without id and fallback");
    }

    T_VALUE? value = values[id];

    if (value == null) {
      T_VALUE? fallback = this.fallback;

      if (fallback == null) {
        throw BuilderException(
          "The given source was not found in values, and no fallback was set.",
        );
      }

      value = fallback;
    }

    return value;
  }
}

class BuilderException implements Exception {
  final String message;

  BuilderException(this.message);

  @override
  String toString() {
    return message;
  }
}
