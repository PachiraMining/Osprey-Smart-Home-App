import 'dart:convert';
import '../../../../l10n/gen/app_l10n.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/weather_location_store.dart';

/// "Switch location" map picker (Tuya style): OSM map with a fixed center
/// pin, an address search box, and Confirm in the app bar. Confirming stores
/// the location as the weather override; "Use current location" clears it.
class WeatherLocationPickerPage extends StatefulWidget {
  const WeatherLocationPickerPage({super.key});

  @override
  State<WeatherLocationPickerPage> createState() =>
      _WeatherLocationPickerPageState();
}

class _WeatherLocationPickerPageState
    extends State<WeatherLocationPickerPage> {
  final MapController _map = MapController();
  final TextEditingController _search = TextEditingController();

  LatLng _center = const LatLng(21.0278, 105.8342); // Hanoi default
  String _label = '';
  List<_Place> _results = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    // Start from the saved override, else last-known GPS, else default.
    final saved = await sl<WeatherLocationStore>().get();
    if (saved != null) {
      _moveTo(LatLng(saved.latitude, saved.longitude), saved.label);
      return;
    }
    try {
      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      _moveTo(LatLng(pos.latitude, pos.longitude), '');
    } catch (_) {/* keep default */}
  }

  void _moveTo(LatLng target, String label) {
    if (!mounted) return;
    setState(() {
      _center = target;
      _label = label;
      _results = const [];
    });
    _map.move(target, 16);
  }

  /// Free-text search via OSM Nominatim (no key; polite UA required).
  Future<void> _runSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&limit=5'
          '&q=${Uri.encodeQueryComponent(q)}');
      final resp = await http.get(uri, headers: {
        'User-Agent': 'osprey-life-app/1.0 (weather location picker)',
      });
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        setState(() {
          _results = [
            for (final e in list.whereType<Map<String, dynamic>>())
              _Place(
                name: e['display_name'] as String? ?? '',
                lat: double.tryParse('${e['lat']}') ?? 0,
                lon: double.tryParse('${e['lon']}') ?? 0,
              ),
          ];
        });
      }
    } catch (_) {
      // Network hiccup — just leave results empty.
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _confirm() async {
    await sl<WeatherLocationStore>().set(WeatherLocation(
      latitude: _center.latitude,
      longitude: _center.longitude,
      label: _label,
    ));
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _useCurrentLocation() async {
    await sl<WeatherLocationStore>().clear();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppL10n.of(context).location,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: Text(
              AppL10n.of(context).confirm,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 16,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  // Dragging the map re-targets the pin (label becomes stale).
                  _center = camera.center;
                  if (_label.isNotEmpty) setState(() => _label = '');
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.dracaena.curtainai',
              ),
            ],
          ),

          // Fixed center pin
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(Icons.location_pin,
                    size: 44, color: Color(0xFFE85D3A)),
              ),
            ),
          ),

          // Search box + results
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _runSearch,
                    decoration: InputDecoration(
                      hintText: AppL10n.of(context).searchAddress,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade500),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_results.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (final r in _results)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_outlined,
                                size: 20, color: AppColors.primary),
                            title: Text(
                              r.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                            onTap: () =>
                                _moveTo(LatLng(r.lat, r.lon), r.name),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Current pin label bubble
          if (_label.isNotEmpty)
            Positioned(
              left: 40,
              right: 40,
              top: MediaQuery.of(context).size.height * 0.32,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    _label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

          // Use current location
          PositionedDirectional(
            end: 16,
            bottom: 28,
            child: FloatingActionButton.small(
              heroTag: 'weather-loc-gps',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _useCurrentLocation,
              tooltip: AppL10n.of(context).useCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

class _Place {
  final String name;
  final double lat;
  final double lon;

  const _Place({required this.name, required this.lat, required this.lon});
}
