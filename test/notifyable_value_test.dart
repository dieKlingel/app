import 'package:dieklingel_app/components/notifyable_value.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockCallBackFunction extends Mock {
  call();
}

void main() {
  group('NotifyableValue', () {
    const String value = "Hallo";
    const String newValue = "Hallo Welt";
    late NotifyableValue<String> notifyableValue;
    final MockCallBackFunction notifyListenerCallback = MockCallBackFunction();

    setUp(() {
      notifyableValue = NotifyableValue(value: value);
      notifyableValue.addListener(notifyListenerCallback);
      reset(notifyListenerCallback);
    });

    test("is initialized with value", () {
      expect(notifyableValue.value, value);
    });

    test("change value and call listener", () {
      notifyableValue.value = newValue;
      expect(notifyableValue.value, newValue);
      verify(notifyListenerCallback()).called(1);

      notifyableValue.value = notifyableValue.value;
      expect(notifyableValue.value, newValue);
      verifyNever(notifyListenerCallback());

      notifyableValue.value = value;
      expect(notifyableValue.value, value);
      verify(notifyListenerCallback()).called(1);
    });

    test("call listener on force ", () {
      notifyableValue.force(newValue);
      expect(notifyableValue.value, newValue);
      verify(notifyListenerCallback()).called(1);

      notifyableValue.force(notifyableValue.value);
      expect(notifyableValue.value, newValue);
      verify(notifyListenerCallback()).called(1);
    });

    test("toString of value", () {
      int nvIntValue = 10;
      NotifyableValue<int> nvInt = NotifyableValue<int>(value: nvIntValue);
      expect(nvInt.toString(), nvIntValue.toString());
      expect(nvInt.value.toString(), nvIntValue.toString());

      String nvStringValue = "Hallo Welt";
      NotifyableValue<String> nvString =
          NotifyableValue<String>(value: nvStringValue);
      expect(nvString.toString(), nvStringValue.toString());
      expect(nvString.value.toString(), nvStringValue.toString());

      Map<String, int> nvMapValue = {"Hallo": 11};
      NotifyableValue<Map<String, int>> nvMap =
          NotifyableValue<Map<String, int>>(value: nvMapValue);
      expect(nvMap.toString(), nvMapValue.toString());
      expect(nvMap.value.toString(), nvMapValue.toString());
    });
  });
}
