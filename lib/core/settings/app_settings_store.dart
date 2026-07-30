import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Đơn vị nhiệt độ hiển thị trong app.
enum TemperatureUnit {
  celsius('C', '°C'),
  fahrenheit('F', '°F');

  const TemperatureUnit(this.code, this.symbol);

  final String code;
  final String symbol;

  static TemperatureUnit fromCode(String? code) =>
      code == 'F' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;

  /// Nhiệt độ luôn được lấy về từ API dưới dạng °C.
  double convertFromCelsius(double celsius) =>
      this == TemperatureUnit.fahrenheit ? celsius * 9 / 5 + 32 : celsius;
}

/// Tuỳ chọn cấp app lưu cục bộ (không đồng bộ server).
///
/// Là [ChangeNotifier] để widget nghe được và đổi ngay khi user chỉnh, không
/// phải khởi động lại app.
class AppSettingsStore extends ChangeNotifier {
  static const _kTemperatureUnit = 'settings_temperature_unit';
  static const _kTouchTone = 'settings_touch_tone';

  final SharedPreferences _prefs;

  AppSettingsStore(this._prefs);

  TemperatureUnit get temperatureUnit =>
      TemperatureUnit.fromCode(_prefs.getString(_kTemperatureUnit));

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await _prefs.setString(_kTemperatureUnit, unit.code);
    notifyListeners();
  }

  bool get touchTone => _prefs.getBool(_kTouchTone) ?? false;

  Future<void> setTouchTone(bool value) async {
    await _prefs.setBool(_kTouchTone, value);
    notifyListeners();
  }

  /// "24°C" / "75°F" — dùng chung mọi nơi hiển thị nhiệt độ để không lệch đơn vị.
  String formatFromCelsius(double? celsius) {
    if (celsius == null) return '--${temperatureUnit.symbol}';
    final unit = temperatureUnit;
    return '${unit.convertFromCelsius(celsius).round()}${unit.symbol}';
  }
}
