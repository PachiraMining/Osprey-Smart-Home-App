import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// Dropdown-style home selector that appears at the top of the screen,
/// similar to the Tuya Smart app design.
class HomeSelectorDropdown {
  /// Shows a dropdown popup anchored near the top of the screen.
  static Future<void> show({
    required BuildContext context,
    required List<HomeEntity> homes,
    required String? selectedHomeId,
    required void Function(String homeId) onSelect,
    required VoidCallback onManageHome,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(60),
      builder: (ctx) => _HomeSelectorPopup(
        homes: homes,
        selectedHomeId: selectedHomeId,
        onSelect: (id) {
          Navigator.pop(ctx);
          onSelect(id);
        },
        onManageHome: () {
          Navigator.pop(ctx);
          onManageHome();
        },
      ),
    );
  }
}

class _HomeSelectorPopup extends StatelessWidget {
  final List<HomeEntity> homes;
  final String? selectedHomeId;
  final void Function(String homeId) onSelect;
  final VoidCallback onManageHome;

  const _HomeSelectorPopup({
    required this.homes,
    required this.selectedHomeId,
    required this.onSelect,
    required this.onManageHome,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            elevation: 8,
            shadowColor: Colors.black.withAlpha(50),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Home list
                  ...homes.map((home) => _HomeRow(
                        home: home,
                        isSelected: home.id == selectedHomeId,
                        onTap: () => onSelect(home.id),
                      )),

                  // Divider
                  const Divider(height: 1, thickness: 1),

                  // Home Management row
                  _ManageHomeRow(onTap: onManageHome),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeRow extends StatelessWidget {
  final HomeEntity home;
  final bool isSelected;
  final VoidCallback onTap;

  const _HomeRow({
    required this.home,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Checkmark or spacer for alignment
            SizedBox(
              width: 28,
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Color(0xFF2196F3),
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 4),

            // Home name
            Expanded(
              child: Text(
                home.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF2196F3)
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageHomeRow extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageHomeRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.tune,
              color: Colors.black54,
              size: 22,
            ),
            SizedBox(width: 12),
            Text(
              'Home Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
