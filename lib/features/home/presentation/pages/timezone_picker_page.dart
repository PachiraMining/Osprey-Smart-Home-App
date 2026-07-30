import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/time/device_timezone.dart';

/// Full-screen searchable IANA timezone picker. Pops with the selected IANA id
/// (e.g. `America/New_York`) or null if the user backs out.
class TimezonePickerPage extends StatefulWidget {
  /// The currently-selected zone, highlighted with a check mark.
  final String? current;
  const TimezonePickerPage({super.key, this.current});

  /// `America/New_York` → `New York` for a friendlier primary label.
  static String label(String iana) =>
      iana.split('/').last.replaceAll('_', ' ');

  @override
  State<TimezonePickerPage> createState() => _TimezonePickerPageState();
}

class _TimezonePickerPageState extends State<TimezonePickerPage> {
  static const _green = Color(0xFF1B4332);

  final _searchCtrl = TextEditingController();
  List<String> _all = const [];
  List<String> _filtered = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final zones = await GetIt.instance<DeviceTimezone>().available();
    if (!mounted) return;
    setState(() {
      _all = zones;
      _filtered = zones;
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((z) => z.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: Text(AppL10n.of(context).timeZone),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppL10n.of(context).searchCityOrRegion,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filtered.isEmpty)
            Expanded(
              child: Center(child: Text(AppL10n.of(context).noMatchingTimeZones)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final z = _filtered[i];
                  final selected = z == widget.current;
                  return ListTile(
                    title: Text(TimezonePickerPage.label(z)),
                    subtitle: Text(
                      z,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    trailing:
                        selected ? const Icon(Icons.check, color: _green) : null,
                    onTap: () => Navigator.pop(context, z),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
