import '../../../../l10n/gen/app_l10n.dart';

import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Bảng chọn nhà kiểu Tuya: panel TRẮNG ĐẶC thả xuống từ mép trên cùng (phủ cả
/// vùng status bar), liệt kê các nhà với dấu check xanh ở nhà đang chọn, dưới
/// cùng là kẻ mảnh rồi tới hàng "Home Management". Phần còn lại của màn tối đi.
///
/// Số đo lấy từ app tham chiếu: nền #FFFFFF, bo đáy 16pt, bước dòng ~56pt,
/// chữ 19pt, chữ cách trái 56pt, kẻ #E5E5E5.
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

/// Xanh của dấu check, đo trực tiếp từ ảnh app tham chiếu.
const _checkBlue = Color(0xFF0E7CBF);

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
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: Container(
              width: double.infinity,
              // Trắng ĐẶC. Bản trước phủ mờ (alpha 200 + blur) nên panel bị đục
              // và ám màu nền; app tham chiếu đo ra #FFFFFF tuyệt đối.
              color: context.surfaces.card,
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

                  // Kẻ mảnh #E5E5E5 rồi tới hàng Home Management — cùng nằm
                  // trong panel trắng, không phải dải trắng tách rời.
                  const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                  _ManageHomeRow(onTap: onManageHome),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Máng cho dấu check — giữ tên thẳng hàng dù có chọn hay không.
            SizedBox(
              width: 36,
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: _checkBlue, size: 26)
                  : null,
            ),
            Expanded(
              child: Text(
                home.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: context.surfaces.textPrimary,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
             SizedBox(
              width: 36,
              child: Icon(Icons.tune_rounded, color: context.surfaces.textPrimary, size: 24),
            ),
            Text(
              AppL10n.of(context).homeManagement,
              style:  TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: context.surfaces.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
