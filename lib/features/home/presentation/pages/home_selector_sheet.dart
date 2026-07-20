import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_entity.dart';

/// Tuya-style home selector: a frosted panel that drops down from the very top
/// of the screen (behind the status bar), listing homes with a blue check on
/// the selected one, and a solid-white rounded "Home Management" band at the
/// bottom. The rest of the screen dims behind it.
class HomeSelectorDropdown {
  /// Shows the dropdown. Kept API-compatible with previous callers.
  static Future<void> show({
    required BuildContext context,
    required List<HomeEntity> homes,
    required String? selectedHomeId,
    required void Function(String homeId) onSelect,
    required VoidCallback onManageHome,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'home-selector',
      barrierColor: Colors.black.withAlpha(80),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, _, __) => _HomeSelectorPopup(
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
      transitionBuilder: (ctx, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        // Drop down from above the top edge, like the reference design.
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
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
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              // Frosted wash over the dimmed page — content behind stays
              // faintly visible, like the reference.
              color: Colors.white.withAlpha(200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Panel extends behind the status bar; content starts below.
                  SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        // Home list — airy rows, blue check on the selected one.
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final home in homes)
                                  _HomeRow(
                                    home: home,
                                    isSelected: home.id == selectedHomeId,
                                    onTap: () => onSelect(home.id),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  // Solid white rounded band — visually detached footer.
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: _ManageHomeRow(onTap: onManageHome),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            // Check gutter — keeps names aligned whether selected or not.
            SizedBox(
              width: 40,
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 26)
                  : null,
            ),
            Expanded(
              child: Text(
                home.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(Icons.tune_rounded, color: Colors.black87, size: 24),
            ),
            Text(
              'Home Management',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
