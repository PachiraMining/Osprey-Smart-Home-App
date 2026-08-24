import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_entity.dart';
import 'package:smart_curtain_app/features/home/domain/home_update_merge.dart';

void main() {
  const current = HomeEntity(
    id: 'h1',
    name: 'Cũ',
    ownerUserId: 'u1',
    geoName: 'Ho Chi Minh City, Vietnam',
    latitude: 10.8231,
    longitude: 106.6297,
    timezone: 'Asia/Ho_Chi_Minh',
  );

  test('đổi mỗi tên thì giữ nguyên toạ độ, geoName và timezone', () {
    // PUT của backend là full-replace: trường nào không gửi sẽ bị XOÁ.
    final merged = mergeHomeUpdate(current: current, name: 'Mới');
    expect(merged.name, 'Mới');
    expect(merged.latitude, 10.8231);
    expect(merged.longitude, 106.6297);
    expect(merged.geoName, 'Ho Chi Minh City, Vietnam');
    expect(merged.timezone, 'Asia/Ho_Chi_Minh');
  });

  test('giá trị mới ghi đè giá trị cũ', () {
    final merged = mergeHomeUpdate(
      current: current,
      name: 'Cũ',
      geoName: 'Tokyo, Japan',
      latitude: 35.6762,
      longitude: 139.6503,
    );
    expect(merged.latitude, 35.6762);
    expect(merged.longitude, 139.6503);
    expect(merged.geoName, 'Tokyo, Japan');
    expect(merged.timezone, 'Asia/Ho_Chi_Minh'); // không đụng tới
  });

  test('giữ nguyên id và ownerUserId', () {
    final merged = mergeHomeUpdate(current: current, name: 'Mới');
    expect(merged.id, 'h1');
    expect(merged.ownerUserId, 'u1');
  });

  test('home chưa có toạ độ thì vẫn để trống, không bịa giá trị', () {
    const bare = HomeEntity(id: 'h2', name: 'Nhà 2');
    final merged = mergeHomeUpdate(current: bare, name: 'Nhà 2 đổi tên');
    expect(merged.latitude, isNull);
    expect(merged.longitude, isNull);
    expect(merged.geoName, isNull);
  });
}
