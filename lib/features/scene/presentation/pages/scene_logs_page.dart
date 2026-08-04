import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/scene_logs_service.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Execution logs timeline (Tuya style): scene/automation runs across the home,
/// grouped by day with a green/red status dot on a vertical timeline.
class SceneLogsPage extends StatefulWidget {
  final String homeId;
  const SceneLogsPage({super.key, required this.homeId});

  @override
  State<SceneLogsPage> createState() => _SceneLogsPageState();
}

class _SceneLogsPageState extends State<SceneLogsPage> {
  late Future<List<SceneLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = GetIt.instance<SceneLogsService>().homeLogs(widget.homeId);
  }


  String _two(int n) => n.toString().padLeft(2, '0');

  /// Thẻ locale đang dùng, để tên tháng/thứ ra đúng ngôn ngữ.
  static String _tag(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.sheet,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,
              size: 20, color: context.surfaces.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppL10n.of(context).logs,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.surfaces.textPrimary)),
      ),
      body: FutureBuilder<List<SceneLogEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data ?? const [];
          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No logs yet.\nScene and automation runs will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          // Group by calendar day, newest first.
          final groups = <DateTime, List<SceneLogEntry>>{};
          for (final e in logs) {
            final day = DateTime(e.time.year, e.time.month, e.time.day);
            (groups[day] ??= []).add(e);
          }
          final days = groups.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final entries = groups[day]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dayHeader(day),
                  for (var j = 0; j < entries.length; j++)
                    _entryRow(
                      entries[j],
                      isLast: j == entries.length - 1,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _dayHeader(DateTime day) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 18, bottom: 6, start: 4, end: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('${day.day}',
              style:  TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.surfaces.textPrimary)),
          const SizedBox(width: 6),
          Text(DateFormat.MMM(_tag(context)).format(day),
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textMuted)),
          const Spacer(),
          Text(DateFormat.EEEE(_tag(context)).format(day),
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _entryRow(SceneLogEntry e, {required bool isLast}) {
    final color =
        e.success ? const Color(0xFF3DBB6B) : const Color(0xFFE05252);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column: dot + connector line.
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 22),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(
                    e.success ? Icons.check : Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFDDE4EC)),
                  ),
              ],
            ),
          ),
          // Card.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.surfaces.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.sceneName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.surfaces.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_two(e.time.hour)}:${_two(e.time.minute)}  '
                      'Processing ${e.success ? 'Succeeded' : 'Failed'}',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
