class Validator<T> {
  final bool Function(T value) validator;
  T value;

  Validator({
    required this.value,
    required this.validator,
  });

  bool isValid() {
    return validator(value);
  }
}
