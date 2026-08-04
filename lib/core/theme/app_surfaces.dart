import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Các màu bề mặt riêng của app, không nằm gọn trong [ColorScheme] của Material.
///
/// Số đo lấy trực tiếp từ ảnh chụp dark mode của app tham chiếu (sample pixel).
/// Điểm mấu chốt: app có **hai họ bề mặt khác nhau**, không phải một —
///
///  * Trang **Home / Scene** giữ ảnh nền, chỉ làm tối đi; thẻ nổi lên trên ảnh
///    nên sáng hơn ([photoCard] `#3C3E3F`).
///  * Trang **danh sách kiểu Settings** bỏ hẳn ảnh, nền đen đặc ([pageBg]
///    `#000000`) với ô nội dung `#191919`.
///
/// Trộn hai họ này làm một sẽ ra sai ở một trong hai chỗ.
@immutable
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  /// Nền trang danh sách (Settings, Room Management…).
  final Color pageBg;

  /// Ô/section nội dung trên [pageBg].
  final Color card;

  /// Bottom sheet, dialog, AppBar.
  final Color sheet;

  /// Thẻ đặt TRÊN ảnh nền (thẻ thiết bị ở Home, thẻ automation ở Scene).
  final Color photoCard;

  /// Nền thanh điều hướng dưới.
  final Color navBar;

  /// Màu icon/nhãn của tab đang chọn. **Đổi theo chế độ**: sáng dùng xanh
  /// thương hiệu, tối dùng cam — đo được ở cùng vị trí pixel trên cả hai ảnh.
  final Color navActive;

  final Color textPrimary;
  final Color textSecondary;

  /// Chữ mờ nhất: tiêu đề nhóm trong sheet, nhãn phụ.
  final Color textMuted;

  final Color divider;

  /// Độ phủ đen lên ảnh nền. 0 = giữ nguyên ảnh (chế độ sáng).
  final double photoDim;

  const AppSurfaces({
    required this.pageBg,
    required this.card,
    required this.sheet,
    required this.photoCard,
    required this.navBar,
    required this.navActive,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.photoDim,
  });

  static const light = AppSurfaces(
    pageBg: Color(0xFFF2F4F7),
    card: Colors.white,
    sheet: Colors.white,
    // Thẻ trên ảnh nền ở chế độ sáng là lớp trắng bán trong.
    photoCard: Color(0x8CFFFFFF),
    navBar: Colors.white,
    navActive: Color(0xFF0E7DC0),
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    divider: Color(0xFFECECEC),
    photoDim: 0,
  );

  static const dark = AppSurfaces(
    pageBg: Color(0xFF000000),
    card: Color(0xFF191919),
    sheet: Color(0xFF1A1A1A),
    photoCard: Color(0xFF3C3E3F),
    navBar: Color(0xFF3E4041),
    navActive: Color(0xFFFF592A),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF9D9E9F),
    textMuted: Color(0xFF5F5F5F),
    divider: Color(0xFF2A2A2A),
    // Ảnh nền tối còn ~#63676A so với bản sáng -> phủ đen khoảng 45%.
    photoDim: 0.45,
  );

  /// Tiện dụng: `context.surfaces.card`.
  static AppSurfaces of(BuildContext context) =>
      Theme.of(context).extension<AppSurfaces>() ?? light;

  @override
  AppSurfaces copyWith({
    Color? pageBg,
    Color? card,
    Color? sheet,
    Color? photoCard,
    Color? navBar,
    Color? navActive,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    double? photoDim,
  }) {
    return AppSurfaces(
      pageBg: pageBg ?? this.pageBg,
      card: card ?? this.card,
      sheet: sheet ?? this.sheet,
      photoCard: photoCard ?? this.photoCard,
      navBar: navBar ?? this.navBar,
      navActive: navActive ?? this.navActive,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      photoDim: photoDim ?? this.photoDim,
    );
  }

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      card: Color.lerp(card, other.card, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      photoCard: Color.lerp(photoCard, other.photoCard, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      photoDim: photoDim + (other.photoDim - photoDim) * t,
    );
  }
}

/// Đọc nhanh bảng bề mặt từ context.
extension AppSurfacesX on BuildContext {
  AppSurfaces get surfaces => AppSurfaces.of(this);
}
