// Placeholder smoke test. The default Flutter counter test does not apply
// here because the app entry widget is `SmartApp` (not `MyApp`) and requires
// the full DI graph to boot.
//
// Real coverage lives in test/features/**/* (BLoC + usecase tests).
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
