import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/device/presentation/pages/schedule_repeat_page.dart';

/// Màn Repeat liệt kê từ Chủ nhật, còn `loops` của backend bắt đầu từ Thứ hai —
/// chỗ dễ lệch nhất nên khoá lại bằng test.
Future<String?> _pickDays(WidgetTester tester, String initial,
    List<String> tapLabels) async {
  String? returned;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          returned = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) => ScheduleRepeatPage(loops: initial),
            ),
          );
        },
        child: const Text('open'),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  for (final label in tapLabels) {
    await tester.tap(find.text(label));
    await tester.pump();
  }

  await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
  await tester.pumpAndSettle();
  return returned;
}

void main() {
  testWidgets('không chọn ngày nào → "0000000" (chạy một lần)', (t) async {
    expect(await _pickDays(t, '0000000', const []), '0000000');
  });

  testWidgets('chọn Mon → bit ĐẦU TIÊN bật', (t) async {
    expect(await _pickDays(t, '0000000', const ['Mon.']), '1000000');
  });

  testWidgets('chọn Sun → bit CUỐI CÙNG bật, không phải bit đầu', (t) async {
    expect(await _pickDays(t, '0000000', const ['Sun.']), '0000001');
  });

  testWidgets('chọn Sat → bit thứ 6', (t) async {
    expect(await _pickDays(t, '0000000', const ['Sat.']), '0000010');
  });

  testWidgets('chọn cả tuần → "1111111"', (t) async {
    expect(
      await _pickDays(t, '0000000',
          const ['Mon.', 'Tues.', 'Wed.', 'Thurs.', 'Fri.', 'Sat.', 'Sun.']),
      '1111111',
    );
  });

  testWidgets('mở với loops có sẵn rồi bỏ chọn → tắt đúng bit', (t) async {
    // 1111100 = Mon..Fri; bỏ Fri còn Mon..Thu.
    expect(await _pickDays(t, '1111100', const ['Fri.']), '1111000');
  });
}
