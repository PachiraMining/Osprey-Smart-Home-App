import 'package:shared_preferences/shared_preferences.dart';

/// A manually chosen weather location ("Switch location" on the weather page).
class WeatherLocation {
  final double latitude;
  final double longitude;
  final String label;

  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

/// Persists the manual weather-location override. When unset, weather follows
/// the device's GPS position.
class WeatherLocationStore {
  static const _latKey = 'weather_loc_lat';
  static const _lonKey = 'weather_loc_lon';
  static const _labelKey = 'weather_loc_label';

  Future<WeatherLocation?> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lon = prefs.getDouble(_lonKey);
      if (lat == null || lon == null) return null;
      return WeatherLocation(
        latitude: lat,
        longitude: lon,
        label: prefs.getString(_labelKey) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> set(WeatherLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, location.latitude);
    await prefs.setDouble(_lonKey, location.longitude);
    await prefs.setString(_labelKey, location.label);
  }

  /// Back to "follow the device GPS".
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_lonKey);
    await prefs.remove(_labelKey);
  }
}
