import 'package:flutter/material.dart';

import '../../../../../core/theme/app_surfaces.dart';
import '../../../../../l10n/gen/app_l10n.dart';
import '../../../domain/entities/effective_time_entity.dart';

/// Khung giờ hiệu lực của automation — ngoài khung thì điều kiện có thoả cũng
/// không nổ. Trả [EffectiveTimeEntity] qua `Navigator.pop`.
class PreconditionPage extends StatefulWidget {
  final EffectiveTimeEntity? existing;

  const PreconditionPage({super.key, this.existing});

  @override
  State<PreconditionPage> createState() => _PreconditionPageState();
}

class _PreconditionPageState extends State<PreconditionPage> {
  late bool _allDay;
  late String _start;
  late String _end;
  late List<bool> _days;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _allDay = e == null || e.isAllDay;
    _start = e?.startTime ?? '18:00';
    _end = e?.endTime ?? '06:00';
    final loops = e?.loops ?? '1111111';
    _days = List.generate(
      7,
      (i) => i < loops.length ? loops[i] == '1' : true,
    );
  }

  String get _loops => _days.map((d) => d ? '1' : '0').join();

  /// Khung vắt qua nửa đêm — backend tính theo NGÀY BẮT ĐẦU, người dùng không
  /// tự đoán được nên phải nói ra.
  bool get _crossesMidnight {
    final s = _start.split(':');
    final e = _end.split(':');
    final sm = int.parse(s[0]) * 60 + int.parse(s[1]);
    final em = int.parse(e[0]) * 60 + int.parse(e[1]);
    return sm > em;
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = (isStart ? _start : _end).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(current[0]),
        minute: int.parse(current[1]),
      ),
    );
    if (picked == null || !mounted) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        _start = text;
      } else {
        _end = text;
      }
    });
  }

  void _save() {
    Navigator.pop(
      context,
      _allDay
          ? const EffectiveTimeEntity(type: 'ALL_DAY')
          : EffectiveTimeEntity(
              type: 'CUSTOM',
              startTime: _start,
              endTime: _end,
              loops: _loops,
              // Để null: backend lấy timezone của home.
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        title: Text(
          l10n.precondition,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: context.surfaces.sheet,
        foregroundColor: context.surfaces.textPrimary,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: context.surfaces.navActive,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _Card(
            children: [
              _RadioRow(
                label: l10n.allDay,
                selected: _allDay,
                onTap: () => setState(() => _allDay = true),
              ),
              Divider(height: 1, color: context.surfaces.divider),
              _RadioRow(
                label: l10n.customTime,
                selected: !_allDay,
                onTap: () => setState(() => _allDay = false),
              ),
            ],
          ),
          if (!_allDay) ...[
            const SizedBox(height: 16),
            _Card(
              children: [
                _ValueRow(
                  label: l10n.startTime,
                  value: _start,
                  onTap: () => _pickTime(isStart: true),
                ),
                Divider(height: 1, color: context.surfaces.divider),
                _ValueRow(
                  label: l10n.endTime,
                  value: _end,
                  onTap: () => _pickTime(isStart: false),
                ),
              ],
            ),
            if (_crossesMidnight)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  l10n.overnightNote,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: context.surfaces.textMuted,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.repeat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.surfaces.textSecondary,
                ),
              ),
            ),
            _DayPicker(
              days: _days,
              onToggle: (i) => setState(() => _days[i] = !_days[i]),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaces.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      );
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15, color: context.surfaces.textPrimary)),
              ),
              if (selected)
                Icon(Icons.check, size: 20, color: context.surfaces.navActive),
            ],
          ),
        ),
      );
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ValueRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 15, color: context.surfaces.textPrimary)),
              ),
              Text(value,
                  style: TextStyle(
                      fontSize: 15, color: context.surfaces.textSecondary)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right,
                  size: 20, color: context.surfaces.textMuted),
            ],
          ),
        ),
      );
}

class _DayPicker extends StatelessWidget {
  final List<bool> days;
  final void Function(int index) onToggle;
  const _DayPicker({required this.days, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // Thứ 2 … Chủ nhật, khớp thứ tự chuỗi loops của backend.
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final on = days[i];
          return GestureDetector(
            onTap: () => onToggle(i),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? context.surfaces.navActive : context.surfaces.card,
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: on ? Colors.white : context.surfaces.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
