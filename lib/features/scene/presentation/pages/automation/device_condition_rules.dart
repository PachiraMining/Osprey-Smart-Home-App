import '../../../domain/entities/data_point_entity.dart';

/// Toán tử hợp lệ theo kiểu DP. Nhóm so sánh lớn/nhỏ chỉ có nghĩa với số.
List<String> operatorsFor(String dpType) => switch (dpType) {
      'VALUE' => const ['==', '!=', '>', '>=', '<', '<='],
      'BOOLEAN' => const ['=='],
      _ => const ['==', '!='],
    };

/// Toán tử chọn sẵn khi người dùng vừa chọn xong DP.
String defaultOperatorFor(String dpType) => operatorsFor(dpType).first;

/// `valueType` gửi lên backend, suy từ `dpType`. ENUM đi đường STRING.
String valueTypeFor(String dpType) => switch (dpType) {
      'VALUE' => 'NUMBER',
      'BOOLEAN' => 'BOOLEAN',
      _ => 'STRING',
    };

/// DP dùng được làm điều kiện — bỏ những DP không đọc lại được trạng thái.
List<DataPointEntity> conditionDataPoints(List<DataPointEntity> all) =>
    all.where((d) => d.isReadable).toList();
