import '../../domain/entities/factory_reset_result.dart';

/// Parse response của POST `.../devices/{deviceId}/factory-reset`.
class FactoryResetResultModel extends FactoryResetResult {
  const FactoryResetResultModel({
    required super.deviceWasOnline,
    required super.deviceUuid,
  });

  factory FactoryResetResultModel.fromJson(Map<String, dynamic> json) {
    return FactoryResetResultModel(
      deviceWasOnline: (json['deviceWasOnline'] ?? false) as bool,
      deviceUuid: (json['deviceUuid'] ?? '') as String,
    );
  }
}
