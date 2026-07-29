import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_popup.dart';

import '../../../../core/theme/scene_style.dart';
import '../../../home/presentation/bloc/home_management_bloc.dart';
import '../../domain/entities/tap_to_run_scene_entity.dart';
import '../bloc/tap_to_run/tap_to_run_bloc.dart';
import '../bloc/tap_to_run/tap_to_run_event.dart';
import '../bloc/tap_to_run/tap_to_run_state.dart';

/// Horizontal strip of Tap-to-Run quick-run pills for the Home tab (Tuya
/// style): each pill carries its scene's color and runs the scene on tap.
/// Renders nothing while there are no scenes.
class TapToRunPills extends StatefulWidget {
  const TapToRunPills({super.key});

  @override
  State<TapToRunPills> createState() => _TapToRunPillsState();
}

class _TapToRunPillsState extends State<TapToRunPills> {
  @override
  void initState() {
    super.initState();
    // The Scene tab normally loads these; kick a load here too so the pills
    // appear even if the user never opened that tab this session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<TapToRunBloc>();
      final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
      if (homeId != null) {
        bloc.add(LoadTapToRunScenesEvent(homeId));
      }
    });
  }

  /// Chạy scene với popup custom (AppPopup) y hệt Common Functions: loading trong
  /// lúc gửi → ✓ success (tự đóng) hoặc ✗ error. Kết quả về qua bloc state
  /// nên await trên stream thay vì Future.
  Future<void> _runScene(
      BuildContext context, TapToRunSceneEntity scene) async {
    final bloc = context.read<TapToRunBloc>();
    AppPopup.loading(context, title: 'Running', message: scene.name);
    bloc.add(ExecuteTapToRunSceneEvent(scene.id));
    // Lọc theo sceneId — bloc concurrent, kết quả của scene khác có thể tới trước.
    final result = await bloc.stream
        .firstWhere(
          (s) => s is TapToRunExecuteResult && s.sceneId == scene.id,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => TapToRunExecuteResult(
            sceneId: scene.id,
            status: 'FAILURE',
            details: 'timeout',
            scenes: const [],
          ),
        ) as TapToRunExecuteResult;
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // đóng loading
    final success = result.status == 'SUCCESS';
    if (success) {
      AppPopup.success(context,
          title: 'Done', message: '"${scene.name}" executed');
    } else {
      AppPopup.error(context,
          title: 'Failed',
          message: 'Could not run "${scene.name}". Please try again.');
    }
  }

  List<TapToRunSceneEntity> _scenesOf(TapToRunState state) => switch (state) {
        TapToRunLoaded(:final scenes) => scenes,
        TapToRunExecuting(:final scenes) => scenes,
        TapToRunExecuteResult(:final scenes) => scenes,
        _ => const <TapToRunSceneEntity>[],
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TapToRunBloc, TapToRunState>(
      builder: (context, state) {
        final scenes = _scenesOf(state);
        if (scenes.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: scenes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final scene = scenes[index];
              final (color, _) = SceneStyle.decode(scene.icon, scene.id);
              return GestureDetector(
                onTap: () => _runScene(context, scene),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    scene.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
