import 'package:flutter/material.dart';

import '../../../../core/theme/app_surfaces.dart';
import '../../../../l10n/gen/app_l10n.dart';
import '../../data/city_catalog.dart';

/// Chọn thành phố để đặt `geoName` + toạ độ cho home.
/// Trả [CityEntry] qua `Navigator.pop`.
class CityPickerPage extends StatefulWidget {
  const CityPickerPage({super.key});

  @override
  State<CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
  final TextEditingController _controller = TextEditingController();
  List<CityEntry> _results = kCityCatalog;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        title: Text(
          l10n.selectCity,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: context.surfaces.sheet,
        foregroundColor: context.surfaces.textPrimary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: (q) => setState(() => _results = searchCities(q)),
              style: TextStyle(color: context.surfaces.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.searchCity,
                hintStyle: TextStyle(color: context.surfaces.textMuted),
                prefixIcon:
                    Icon(Icons.search, color: context.surfaces.textMuted),
                filled: true,
                fillColor: context.surfaces.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final c = _results[i];
                return InkWell(
                  onTap: () => Navigator.pop(context, c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.surfaces.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name,
                            style: TextStyle(
                                fontSize: 15,
                                color: context.surfaces.textPrimary),
                          ),
                        ),
                        Text(
                          c.country,
                          style: TextStyle(
                              fontSize: 13,
                              color: context.surfaces.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
