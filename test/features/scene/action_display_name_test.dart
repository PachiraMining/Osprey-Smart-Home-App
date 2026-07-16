import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
import 'package:smart_curtain_app/features/scene/data/models/scene_action_model.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_action_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/automation_detail_page.dart';

HomeDeviceEntity _device(String deviceId, String name) => HomeDeviceEntity(
      id: 'row-$deviceId',
      smartHomeId: 'home-1',
      deviceId: deviceId,
      deviceName: name,
    );

void main() {
  group('SceneActionModel persists display name + function', () {
    test('toJson includes deviceName and functionName when present', () {
      const m = SceneActionModel(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        executorProperty: {'dpId': 1, 'dpValue': 'on'},
        deviceName: 'Living Room Curtain',
        functionName: 'Open',
      );
      final json = m.toJson();
      expect(json['deviceName'], 'Living Room Curtain');
      expect(json['functionName'], 'Open');
    });

    test('fromJson reads them back (round-trip after reload)', () {
      final m = SceneActionModel.fromJson(const {
        'actionType': 'DEVICE_CONTROL',
        'entityId': 'dev-1',
        'executorProperty': {'dpId': 1, 'dpValue': 'on'},
        'deviceName': 'Living Room Curtain',
        'functionName': 'Open',
      });
      expect(m.deviceName, 'Living Room Curtain');
      expect(m.functionName, 'Open');
    });

    test('omits the keys when null (no empty pollution)', () {
      const m = SceneActionModel(actionType: 'DELAY');
      final json = m.toJson();
      expect(json.containsKey('deviceName'), isFalse);
      expect(json.containsKey('functionName'), isFalse);
    });
  });

  group('resolveActionDeviceName (fallback for legacy records)', () {
    final devices = [
      _device('dev-1', 'Bedroom Light'),
      _device('dev-2', 'Kitchen Fan'),
    ];

    test('prefers the in-memory/parsed deviceName when set', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-1',
        deviceName: 'Custom Name',
      );
      expect(resolveActionDeviceName(action, devices), 'Custom Name');
    });

    test('looks up by entityId when deviceName is missing (legacy record)', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'dev-2',
      );
      expect(resolveActionDeviceName(action, devices), 'Kitchen Fan');
    });

    test('falls back to "Device" when the id is unknown', () {
      const action = SceneActionEntity(
        actionType: 'DEVICE_CONTROL',
        entityId: 'ghost',
      );
      expect(resolveActionDeviceName(action, devices), 'Device');
    });
  });
}
