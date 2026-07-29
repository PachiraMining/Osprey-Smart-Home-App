import 'package:get_it/get_it.dart';

import '../../../home/domain/entities/home_device_entity.dart';
import '../../domain/entities/data_point_entity.dart';
import '../../domain/entities/scene_action_entity.dart';
import '../../domain/usecases/get_device_data_points.dart';

/// Artwork dùng cho curtain track, khớp với card thiết bị ở Home tab.
const String kCurtainTrackAsset = 'assets/icons/curtain_track.png';

/// `true`/`false` của DP BOOLEAN đọc là On/Off cho dễ hiểu.
String formatDpValue(dynamic value) => switch (value) {
      true => 'On',
      false => 'Off',
      null => '',
      _ => '$value',
    };

/// Dòng mô tả hành động: `"Control: close"`, `"Mode: morning"`.
///
/// Tên chức năng ưu tiên [SceneActionEntity.functionName] (app tự lưu khi tạo
/// scene), sau đó tới [dpNames] tra từ datapoints — scene tạo ở nơi khác chỉ có
/// dpId. Hết cách mới hiện dpId thô để không bỏ trống.
String actionFunctionLabel(
  SceneActionEntity action,
  Map<String, String> dpNames,
) {
  final dp = action.executorProperty;
  final dpId = dp?['dpId'];
  final name = action.functionName ?? dpNames['${action.entityId}:$dpId'];
  final value = formatDpValue(dp?['dpValue']);
  return name != null ? '$name: $value' : 'dpId $dpId: $value';
}

/// Tra tên chức năng cho mọi action DEVICE_CONTROL, khoá `'<entityId>:<dpId>'`.
/// Datapoints được cache theo device profile nên nhiều action cùng loại thiết
/// bị chỉ gọi API một lần.
Future<Map<String, String>> resolveDpNames({
  required List<SceneActionEntity> actions,
  required List<HomeDeviceEntity> devices,
  GetDeviceDataPoints? useCase,
}) async {
  if (devices.isEmpty || actions.isEmpty) return const {};
  final resolver = useCase ??
      (GetIt.instance.isRegistered<GetDeviceDataPoints>()
          ? GetIt.instance<GetDeviceDataPoints>()
          : null);
  if (resolver == null) return const {};

  final byProfile = <String, List<DataPointEntity>>{};
  final resolved = <String, String>{};

  for (final action in actions) {
    if (action.actionType != 'DEVICE_CONTROL') continue;
    final entityId = action.entityId;
    final dpId = action.executorProperty?['dpId'];
    if (entityId == null || dpId is! int) continue;
    if (resolved.containsKey('$entityId:$dpId')) continue;

    String? profileId;
    for (final d in devices) {
      if (d.deviceId == entityId) {
        profileId = d.deviceProfileId;
        break;
      }
    }
    if (profileId == null || profileId.isEmpty) continue;

    var dataPoints = byProfile[profileId];
    if (dataPoints == null) {
      final result = await resolver(profileId);
      dataPoints = result.fold<List<DataPointEntity>>(
        (_) => const <DataPointEntity>[],
        (v) => v,
      );
      byProfile[profileId] = dataPoints;
    }
    for (final dp in dataPoints) {
      if (dp.dpId == dpId) {
        resolved['$entityId:$dpId'] = dp.name;
        break;
      }
    }
  }
  return resolved;
}

/// Thiết bị hiện tại theo `entityId` của action (null nếu đã gỡ khỏi home).
HomeDeviceEntity? deviceOfAction(
  SceneActionEntity action,
  List<HomeDeviceEntity> devices,
) {
  final entityId = action.entityId;
  if (entityId == null) return null;
  for (final d in devices) {
    if (d.deviceId == entityId) return d;
  }
  return null;
}
