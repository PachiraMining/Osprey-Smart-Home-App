import 'entities/home_entity.dart';

/// Ghép giá trị người dùng vừa sửa lên bản ghi home đang có.
///
/// Endpoint PUT của backend là **full-replace**: trường nào không gửi sẽ bị
/// xoá. Màn đổi tên chỉ truyền `name`, nên nếu không lấp lại các trường còn lại
/// từ [current] thì toạ độ và timezone sẽ mất — kéo theo automation theo lịch
/// chạy sai giờ và automation thời tiết chết âm thầm.
HomeEntity mergeHomeUpdate({
  required HomeEntity current,
  required String name,
  String? geoName,
  double? latitude,
  double? longitude,
  String? timezone,
}) {
  return HomeEntity(
    id: current.id,
    name: name,
    ownerUserId: current.ownerUserId,
    geoName: geoName ?? current.geoName,
    latitude: latitude ?? current.latitude,
    longitude: longitude ?? current.longitude,
    timezone: timezone ?? current.timezone,
  );
}
