import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/scene_style.dart';
import '../../../scene/presentation/widgets/scene_run_feedback.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../../scene/domain/entities/automation_scene_entity.dart';
import '../../../scene/domain/entities/scene_action_entity.dart';
import '../../../scene/domain/entities/tap_to_run_scene_entity.dart';
import '../../../scene/domain/usecases/execute_tap_to_run_scene.dart';
import '../../../scene/domain/usecases/get_automations.dart';
import '../../../scene/domain/usecases/get_tap_to_run_scenes.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Các scene và automation có liên quan tới MỘT thiết bị.
///
/// Lọc theo `entityId` của action, nên chỉ hiện những gì thật sự điều khiển
/// thiết bị đang xem.
class DeviceScenesPage extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceScenesPage({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceScenesPage> createState() => _DeviceScenesPageState();
}

class _DeviceScenesPageState extends State<DeviceScenesPage> {

  List<TapToRunSceneEntity> _tapToRun = const [];
  List<AutomationSceneEntity> _automations = const [];
  bool _loading = true;
  String? _runningId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  bool _usesDevice(Iterable<SceneActionEntity> actions) =>
      actions.any((a) =>
          a.actionType == 'DEVICE_CONTROL' && a.entityId == widget.deviceId);

  Future<void> _load() async {
    if (!mounted) return;
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (homeId == null) {
      setState(() => _loading = false);
      return;
    }
    final scenes = await GetIt.instance<GetTapToRunScenes>()(homeId);
    final automations = await GetIt.instance<GetAutomations>()(homeId);
    if (!mounted) return;
    setState(() {
      scenes.fold(
        (_) {},
        (list) =>
            _tapToRun = list.where((s) => _usesDevice(s.actions)).toList(),
      );
      automations.fold(
        (_) {},
        (list) =>
            _automations = list.where((a) => _usesDevice(a.actions)).toList(),
      );
      _loading = false;
    });
  }

  Future<void> _run(TapToRunSceneEntity scene) async {
    if (_runningId != null) return;
    setState(() => _runningId = scene.id);
    // Dùng CHUNG luồng popup với pill Tap-to-Run ở Home tab.
    await showSceneRunFeedback(
      context: context,
      sceneName: scene.name,
      run: () async {
        final result = await GetIt.instance<ExecuteTapToRunScene>()(scene.id);
        return result.fold(
          (_) => false,
          (data) => (data['status'] as String? ?? 'SUCCESS') == 'SUCCESS',
        );
      },
    );
    if (mounted) setState(() => _runningId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.surfaces.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.deviceName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_tapToRun.isEmpty && _automations.isEmpty)
              ? Center(
                  child: Text(
                    AppL10n.of(context).noScenesUseThisDevice,
                    style: TextStyle(fontSize: 16, color: context.surfaces.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    if (_tapToRun.isNotEmpty) ...[
                       _SectionLabel(AppL10n.of(context).tapToRunLabel),
                      _grid([
                        for (final scene in _tapToRun)
                          _SceneCell(
                            title: scene.name,
                            color: SceneStyle.decode(scene.icon, scene.id).$1,
                            busy: _runningId == scene.id,
                            onTap: () => _run(scene),
                          ),
                      ]),
                    ],
                    if (_automations.isNotEmpty) ...[
                      const SizedBox(height: 22),
                       _SectionLabel(AppL10n.of(context).automation),
                      _grid([
                        for (final a in _automations)
                          _SceneCell(
                            title: a.name,
                            color: SceneStyle.decode(a.icon, a.id).$1,
                            subtitle: a.conditionSummary,
                            dimmed: !a.enabled,
                          ),
                      ]),
                    ],
                  ],
                ),
    );
  }

  Widget _grid(List<Widget> children) => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style:  TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: context.surfaces.textPrimary,
        ),
      ),
    );
  }
}

/// Thẻ màu: tên ở góc trên-trái, dấu "…" mờ ở góc dưới-phải.
class _SceneCell extends StatelessWidget {
  final String title;
  final Color color;
  final String? subtitle;
  final bool busy;
  final bool dimmed;
  final VoidCallback? onTap;

  const _SceneCell({
    required this.title,
    required this.color,
    this.subtitle,
    this.busy = false,
    this.dimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dimmed ? color.withValues(alpha: 0.45) : color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        '• • •',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
