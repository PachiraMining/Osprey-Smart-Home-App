import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_curtain_app/core/settings/app_settings_store.dart';
import 'package:smart_curtain_app/core/settings/cache_manager.dart';

void main() {
  group('TemperatureUnit', () {
    test('quy đổi từ °C: 0 → 32°F, 100 → 212°F', () {
      expect(TemperatureUnit.fahrenheit.convertFromCelsius(0), 32);
      expect(TemperatureUnit.fahrenheit.convertFromCelsius(100), 212);
    });

    test('°C giữ nguyên giá trị', () {
      expect(TemperatureUnit.celsius.convertFromCelsius(24), 24);
    });

    test('mã lạ / null → mặc định °C, không ném', () {
      expect(TemperatureUnit.fromCode(null), TemperatureUnit.celsius);
      expect(TemperatureUnit.fromCode('X'), TemperatureUnit.celsius);
    });
  });

  group('AppSettingsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('mặc định là °C và touch tone tắt', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      expect(store.temperatureUnit, TemperatureUnit.celsius);
      expect(store.touchTone, isFalse);
    });

    test('đổi đơn vị thì lưu lại và format theo đơn vị mới', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      expect(store.formatFromCelsius(24), '24°C');
      await store.setTemperatureUnit(TemperatureUnit.fahrenheit);
      expect(store.temperatureUnit, TemperatureUnit.fahrenheit);
      expect(store.formatFromCelsius(24), '75°F');
    });

    test('nhiệt độ null → hiện gạch, kèm ĐÚNG đơn vị đang chọn', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      expect(store.formatFromCelsius(null), '--°C');
      await store.setTemperatureUnit(TemperatureUnit.fahrenheit);
      expect(store.formatFromCelsius(null), '--°F');
    });

    test('thông báo cho listener khi tuỳ chọn đổi', () async {
      final store = AppSettingsStore(await SharedPreferences.getInstance());
      var notified = 0;
      store.addListener(() => notified++);
      await store.setTemperatureUnit(TemperatureUnit.fahrenheit);
      await store.setTouchTone(true);
      expect(notified, 2);
    });
  });

  group('CacheManager.formatBytes', () {
    test('MB có 2 chữ số thập phân', () {
      expect(CacheManager.formatBytes(28048917), '26.75M');
    });

    test('KB làm tròn', () {
      expect(CacheManager.formatBytes(2048), '2K');
    });

    test('dưới 1KB tính theo byte', () {
      expect(CacheManager.formatBytes(512), '512B');
      expect(CacheManager.formatBytes(0), '0B');
    });
  });
}
