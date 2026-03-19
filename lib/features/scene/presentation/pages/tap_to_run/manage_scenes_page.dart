import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tap_to_run_scene_entity.dart';
import '../../bloc/tap_to_run/tap_to_run_bloc.dart';
import '../../bloc/tap_to_run/tap_to_run_event.dart';
import '../../bloc/tap_to_run/tap_to_run_state.dart';

/// Manage Tap-to-Run scenes: reorder + delete (iOS-style edit list).
class ManageScenesPage extends StatelessWidget {
  const ManageScenesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Tap-to-Run',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Finish',
              style: TextStyle(color: Color(0xFF2196F3), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TapToRunBloc, TapToRunState>(
        builder: (context, state) {
          final scenes = state is TapToRunLoaded
              ? state.scenes
              : state is TapToRunExecuteResult
                  ? state.scenes
                  : <TapToRunSceneEntity>[];

          if (scenes.isEmpty) {
            return Center(
              child: Text('No scenes', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return _SceneManageRow(
                scene: scene,
                onDelete: () {
                  context.read<TapToRunBloc>().add(DeleteTapToRunSceneEvent(scene.id));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SceneManageRow extends StatefulWidget {
  final TapToRunSceneEntity scene;
  final VoidCallback onDelete;

  const _SceneManageRow({required this.scene, required this.onDelete});

  @override
  State<_SceneManageRow> createState() => _SceneManageRowState();
}

class _SceneManageRowState extends State<_SceneManageRow> {
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Red minus button
              GestureDetector(
                onTap: () => setState(() => _showDelete = !_showDelete),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Scene name
              Expanded(
                child: Text(
                  widget.scene.name,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.menu, size: 22, color: Colors.grey.shade400),
              ),
              // Delete button (slides in)
              if (_showDelete)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
