import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

/// One execution-log entry (a scene/automation run).
class SceneLogEntry {
  final DateTime time;
  final String sceneName;
  final bool success;
  final String? details;
  final String? triggerType;

  const SceneLogEntry({
    required this.time,
    required this.sceneName,
    required this.success,
    this.details,
    this.triggerType,
  });
}

/// Aggregates execution logs across every scene in a home (the backend only
/// exposes logs per scene → fetch all in parallel and merge, newest first).
class SceneLogsService {
  final ApiClient apiClient;
  SceneLogsService(this.apiClient);

  Future<List<SceneLogEntry>> homeLogs(String homeId) async {
    final scenesResp = await apiClient.get(ApiEndpoints.homeScenes(homeId));
    final scenes = (scenesResp.data as List?) ?? const [];
    final ids = <String>[];
    for (final s in scenes) {
      if (s is Map) {
        final id = s['id'] is Map ? s['id']['id'] : s['id'];
        if (id is String) ids.add(id);
      }
    }
    final lists = await Future.wait(ids.map(_sceneLogs));
    final all = lists.expand((e) => e).toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return all;
  }

  Future<List<SceneLogEntry>> _sceneLogs(String sceneId) async {
    try {
      final resp = await apiClient.get(ApiEndpoints.sceneLogs(sceneId));
      final list = (resp.data as List?) ?? const [];
      return list.whereType<Map>().map((m) {
        final det = m['executionDetails'];
        return SceneLogEntry(
          time: DateTime.fromMillisecondsSinceEpoch(
              (m['createdTime'] as num?)?.toInt() ?? 0),
          sceneName:
              (det is Map ? det['sceneName'] as String? : null) ?? 'Scene',
          success: (m['status'] as String?)?.toUpperCase() == 'SUCCESS',
          details: det is Map ? det['details'] as String? : null,
          triggerType: m['triggerType'] as String?,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
