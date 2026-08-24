import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/data/city_catalog.dart';

void main() {
  test('bảng thành phố có toạ độ hợp lệ', () {
    expect(kCityCatalog, isNotEmpty);
    for (final c in kCityCatalog) {
      expect(c.latitude, inInclusiveRange(-90, 90), reason: c.name);
      expect(c.longitude, inInclusiveRange(-180, 180), reason: c.name);
      expect(c.name.trim(), isNotEmpty);
      expect(c.country.trim(), isNotEmpty);
    }
  });

  test('tìm không phân biệt hoa thường và dấu cách thừa', () {
    expect(searchCities('  ho chi  ').map((c) => c.name),
        contains('Ho Chi Minh City'));
  });

  test('tìm được theo tên quốc gia', () {
    expect(searchCities('vietnam').length, greaterThan(1));
  });

  test('không có thành phố trùng tên trong cùng quốc gia', () {
    final keys = kCityCatalog.map((c) => '${c.name}|${c.country}').toList();
    expect(keys.toSet().length, keys.length);
  });

  test('chuỗi tìm rỗng trả về toàn bộ danh sách', () {
    expect(searchCities('   ').length, kCityCatalog.length);
  });
}
