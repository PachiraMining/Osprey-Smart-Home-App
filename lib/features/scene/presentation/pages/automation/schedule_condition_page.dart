import 'package:flutter/material.dart';
import 'package:smart_curtain_app/core/theme/app_colors.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/schedule_condition_entity.dart';

class ScheduleConditionPage extends StatefulWidget {
  final ScheduleConditionEntity? existing;

  const ScheduleConditionPage({super.key, this.existing});

  @override
  State<ScheduleConditionPage> createState() => _ScheduleConditionPageState();
}

class _ScheduleConditionPageState extends State<ScheduleConditionPage> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;
  // API loops order: [MON TUE WED THU FRI SAT SUN] index 0-6
  late List<bool> _days;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      final parts = e.time.split(':');
      _selectedHour = int.tryParse(parts[0]) ?? 12;
      _selectedMinute =
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      _days = List.generate(
          7, (i) => i < e.loops.length && e.loops[i] == '1');
    } else {
      _selectedHour = TimeOfDay.now().hour;
      _selectedMinute = TimeOfDay.now().minute;
      _days = List.filled(7, false); // Once by default
    }
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String get _loopsString => _days.map((d) => d ? '1' : '0').join();

  bool get _isOneTime => !_days.contains(true);

  String get _repeatDisplayText {
    final loops = _loopsString;
    if (_isOneTime) return 'Once';
    if (loops == '1111111') return 'Every day';
    if (loops == '0111110') return 'Mon - Fri';
    if (loops == '0000011') return 'Sat - Sun';
    // Custom: show abbreviated day names
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = <String>[];
    for (var i = 0; i < 7; i++) {
      if (_days[i]) active.add(labels[i]);
    }
    return active.join(', ');
  }

  void _next() {
    final timeStr =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';

    String? dateStr;
    if (_isOneTime) {
      // Default to tomorrow for one-time
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final y = tomorrow.year.toString().padLeft(4, '0');
      final m = tomorrow.month.toString().padLeft(2, '0');
      final d = tomorrow.day.toString().padLeft(2, '0');
      dateStr = '$y$m$d';
    }

    final condition = ScheduleConditionEntity(
      conditionType: 'SCHEDULE',
      timeZoneId: 'Asia/Ho_Chi_Minh',
      loops: _loopsString,
      time: timeStr,
      date: dateStr,
    );
    Navigator.pop(context, condition);
  }

  Future<void> _openRepeatPage() async {
    final result = await Navigator.push<List<bool>>(
      context,
      MaterialPageRoute(
        builder: (_) => _RepeatPage(days: List.of(_days)),
      ),
    );
    if (result != null) {
      setState(() => _days = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Schedule',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: _next,
            child: const Text('Next',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Repeat row ──
          GestureDetector(
            onTap: _openRepeatPage,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text('Repeat',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const Spacer(),
                  Text(_repeatDisplayText,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Execution Time label ──
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: const Text('Execution Time',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ),

          // ── Scroll wheel picker ──
          Container(
            color: AppColors.surface,
            height: 220,
            child: Stack(
              children: [
                // Selection indicator lines
                Center(
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.textMuted),
                        bottom: BorderSide(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                // Wheels
                Row(
                  children: [
                    // Hour wheel
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 44,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _selectedHour = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (ctx, index) {
                            final isSelected = index == _selectedHour;
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 17,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Minute wheel
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 44,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _selectedMinute = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 60,
                          builder: (ctx, index) {
                            final isSelected = index == _selectedMinute;
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 17,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repeat Page — full-page day selector (matches Tuya UI)
// ─────────────────────────────────────────────────────────────────────────────
class _RepeatPage extends StatefulWidget {
  /// API loops order: [MON TUE WED THU FRI SAT SUN] index 0-6
  final List<bool> days;

  const _RepeatPage({required this.days});

  @override
  State<_RepeatPage> createState() => _RepeatPageState();
}

class _RepeatPageState extends State<_RepeatPage> {
  late List<bool> _days;

  // UI shows Sun first, but API loops order is Mon(0)..Sun(6)
  // Map UI index → API index
  static const _uiOrder = [6, 0, 1, 2, 3, 4, 5]; // Sun, Mon, Tue, Wed, Thu, Fri, Sat
  static const _uiLabels = ['Sun.', 'Mon.', 'Tues.', 'Wed.', 'Thurs.', 'Fri.', 'Sat.'];

  @override
  void initState() {
    super.initState();
    _days = List.of(widget.days);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _days);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 20, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context, _days),
          ),
          centerTitle: true,
          title: const Text('Repeat',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'The action will be carried out only once if you do not select any day of the week.',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),

            // Day list
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: List.generate(_uiLabels.length, (uiIndex) {
                  final apiIndex = _uiOrder[uiIndex];
                  final isSelected = _days[apiIndex];
                  return Column(
                    children: [
                      if (uiIndex > 0)
                        const Divider(
                            height: 1,
                            indent: 20,
                            color: AppColors.borderSubtle),
                      GestureDetector(
                        onTap: () => setState(
                            () => _days[apiIndex] = !_days[apiIndex]),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              Text(
                                _uiLabels[uiIndex],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary),
                              ),
                              const Spacer(),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
