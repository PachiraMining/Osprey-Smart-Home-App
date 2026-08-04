import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
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
  static const _kLocale = 'settings_locale';
  static const _kHomeGrid = 'settings_home_grid_view';
  static const _kThemeMode = 'settings_theme_mode';

  /// Ngôn ngữ app hỗ trợ, kèm tên gọi BẰNG CHÍNH ngôn ngữ đó — người đang mắc
  /// kẹt ở thứ tiếng lạ vẫn tìm được tiếng của mình. Thứ tự này là thứ tự hiện
  /// trong trang Language.
  static const supportedLanguages = <(Locale, String)>[
    (Locale('en'), 'English'),
    (Locale('zh'), '简体中文'),
    (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), '繁體中文'),
    (Locale('es'), 'español'),
    (Locale('fr'), 'français'),
    (Locale('de'), 'Deutsch'),
    (Locale('pt'), 'português'),
    (Locale('it'), 'italiano'),
    (Locale('ru'), 'русский язык'),
    (Locale('ar'), 'العربية'),
    (Locale('ja'), '日本語'),
    (Locale('ko'), '한국어'),
    (Locale('es', '419'), 'Español (latinoamérica)'),
    (Locale('pt', 'BR'), 'Portugues (Brasil)'),
  ];

  final SharedPreferences _prefs;

  AppSettingsStore(this._prefs);

  TemperatureUnit get temperatureUnit =>
      TemperatureUnit.fromCode(_prefs.getString(_kTemperatureUnit));

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await _prefs.setString(_kTemperatureUnit, unit.code);
    notifyListeners();
  }

  /// `null` = theo ngôn ngữ hệ thống (mặc định).
  ///
  /// Lưu dạng thẻ đầy đủ (`zh_Hant`, `pt_BR`) chứ KHÔNG chỉ mã ngôn ngữ, nếu
  /// không sẽ mất phân biệt Hán phồn/giản và các biến thể vùng.
  Locale? get locale {
    final tag = _prefs.getString(_kLocale);
    if (tag == null || tag.isEmpty) return null;
    for (final (candidate, _) in supportedLanguages) {
      if (_tagOf(candidate) == tag) return candidate;
    }
    return null;
  }

  /// Truyền `null` để quay về theo hệ thống.
  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, _tagOf(value));
    }
    notifyListeners();
  }

  /// Tên hiển thị của ngôn ngữ đang chọn; `null` khi đang theo hệ thống.
  String? get localeLabel {
    final current = locale;
    if (current == null) return null;
    for (final (candidate, label) in supportedLanguages) {
      if (_tagOf(candidate) == _tagOf(current)) return label;
    }
    return null;
  }

  static String _tagOf(Locale l) => [
        l.languageCode,
        if (l.scriptCode != null) l.scriptCode!,
        if (l.countryCode != null) l.countryCode!,
      ].join('_');

  /// Sáng / tối / theo hệ thống. Mặc định theo hệ thống.
  ThemeMode get themeMode => switch (_prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeMode, mode.name);
    notifyListeners();
  }

  /// Màn Home hiện thiết bị dạng lưới 2 cột thay vì danh sách 1 cột.
  /// Mặc định false = danh sách, giống hành vi cũ.
  bool get homeGridView => _prefs.getBool(_kHomeGrid) ?? false;

  Future<void> setHomeGridView(bool value) async {
    await _prefs.setBool(_kHomeGrid, value);
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
