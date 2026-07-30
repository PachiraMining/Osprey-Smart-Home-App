import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';

/// Chọn ngày lặp cho một lịch hẹn giờ.
///
/// Trả về chuỗi `loops` 7 ký tự theo thứ tự **MON→SUN** mà backend dùng
/// ("1" = chạy, "0" = bỏ qua). Không chọn ngày nào ⇒ `"0000000"` = chạy một lần.
class ScheduleRepeatPage extends StatefulWidget {
  final String loops;

  const ScheduleRepeatPage({super.key, required this.loops});

  @override
  State<ScheduleRepeatPage> createState() => _ScheduleRepeatPageState();
}

class _ScheduleRepeatPageState extends State<ScheduleRepeatPage> {
  static const _pageBg = Color(0xFFF2F4F7);

  /// Thứ tự hiển thị bắt đầu từ Chủ nhật, nhưng `loops` lại bắt đầu từ Thứ hai
  /// → mỗi dòng mang sẵn chỉ số của nó trong `loops`.
  static List<(String, int)> _rowsFor(AppL10n l10n) => <(String, int)>[
        (l10n.daySunShort, 6),
        (l10n.dayMonShort, 0),
        (l10n.dayTueShort, 1),
        (l10n.dayWedShort, 2),
        (l10n.dayThuShort, 3),
        (l10n.dayFriShort, 4),
        (l10n.daySatShort, 5),
      ];

  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    final loops = widget.loops.padRight(7, '0');
    _selected = [for (var i = 0; i < 7; i++) loops[i] == '1'];
  }

  String get _loops =>
      [for (final on in _selected) on ? '1' : '0'].join();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // Không có nút Save: thoát bằng nút back là áp dụng luôn, giống Tuya.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _loops);
      },
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: _pageBg,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context, _loops),
          ),
          title: Text(
            AppL10n.of(context).repeat,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text(
                AppL10n.of(context).runOnceIfNoDayPicked,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  for (final (label, index) in _rowsFor(AppL10n.of(context)))
                    InkWell(
                      onTap: () => setState(
                          () => _selected[index] = !_selected[index]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.black87),
                              ),
                            ),
                            _RadioDot(selected: _selected[index]),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF2ECC71) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFF2ECC71) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 17, color: Colors.white)
          : null,
    );
  }
}
