import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/schedule_condition_page.dart';

void main() {
  group('oneTimeDateString — a "once" schedule fires today when the time is '
      'still ahead, else tomorrow', () {
    test('time still ahead today → today', () {
      final now = DateTime(2026, 7, 16, 16, 15);
      expect(oneTimeDateString(now, 18, 0), '20260716');
    });

    test('time already passed today → tomorrow', () {
      final now = DateTime(2026, 7, 16, 16, 15);
      expect(oneTimeDateString(now, 9, 0), '20260717');
    });

    test('the current minute counts as today (seconds must not flip it)', () {
      // Default picker time == now; the 30s in `now` must not push it to tomorrow.
      final now = DateTime(2026, 7, 16, 16, 15, 30);
      expect(oneTimeDateString(now, 16, 15), '20260716');
    });

    test('one minute before now → tomorrow', () {
      final now = DateTime(2026, 7, 16, 16, 15, 30);
      expect(oneTimeDateString(now, 16, 14), '20260717');
    });

    test('rolls over month/year boundary', () {
      final now = DateTime(2026, 12, 31, 23, 59);
      expect(oneTimeDateString(now, 1, 0), '20270101');
    });
  });
}
