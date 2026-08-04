import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_surfaces.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Light theme for the Osprey Life app. Distinct from typical smart-home Material
/// defaults: sand/cream background, terracotta primary, warm accent, larger
/// corner radii, custom Plus Jakarta Sans typography.
class AppTheme {
  AppTheme._();

  /// Theme sáng.
  static ThemeData get light => _build(
        brightness: Brightness.light,
        s: AppSurfaces.light,
        colorScheme: _lightScheme,
      );

  /// Theme tối. Dùng CHUNG hàm dựng với bản sáng — mọi khác biệt nằm gọn trong
  /// [AppSurfaces], nên sửa một chỗ là cả hai chế độ đổi theo.
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        s: AppSurfaces.dark,
        colorScheme: _darkScheme,
      );

  static const _lightScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.primarySubtle,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.accentSubtle,
      onSecondaryContainer: AppColors.accentDark,
      tertiary: AppColors.info,
      onTertiary: AppColors.textInverse,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceMuted,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      onError: AppColors.textInverse,
    outline: AppColors.border,
    outlineVariant: AppColors.borderSubtle,
  );

  /// Bảng màu tối: giữ nguyên màu thương hiệu, chỉ đổi bề mặt và màu chữ.
  static const _darkScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: Color(0xFF06121F),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primarySubtle,
    secondary: AppColors.accent,
    onSecondary: Color(0xFF06121F),
    secondaryContainer: AppColors.accentDark,
    onSecondaryContainer: AppColors.accentSubtle,
    tertiary: AppColors.info,
    onTertiary: Color(0xFF06121F),
    surface: Color(0xFF191919),
    onSurface: Color(0xFFE8E8E8),
    surfaceContainerHighest: Color(0xFF242424),
    onSurfaceVariant: Color(0xFF9D9E9F),
    error: AppColors.error,
    onError: Color(0xFF06121F),
    outline: Color(0xFF3A3A3A),
    outlineVariant: Color(0xFF2A2A2A),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppSurfaces s,
    required ColorScheme colorScheme,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: s.pageBg,
      canvasColor: s.card,
      dividerColor: s.divider,
      splashColor: AppColors.primary.withAlpha(15),
      highlightColor: AppColors.primary.withAlpha(10),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      primaryTextTheme: TextTheme(
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textInverse),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: s.pageBg,
        foregroundColor: s.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: s.textPrimary),
        iconTheme: IconThemeData(color: s.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: s.card,
        elevation: 0,
        shadowColor: AppColors.shadowSoft,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: s.divider, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: s.navActive,
        unselectedItemColor: s.textMuted,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          elevation: 0,
          shadowColor: AppColors.shadow,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 56),
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: s.textMuted),
        labelStyle: AppTypography.labelMedium.copyWith(color: s.textSecondary),
        floatingLabelStyle: AppTypography.labelMedium
            .copyWith(color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.surface
              : AppColors.surfaceMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: AppColors.textInverse),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.sheet,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: s.textPrimary),
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: s.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.sheet,
        elevation: 0,
        modalBackgroundColor: s.sheet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: s.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: s.textPrimary,
        size: 22,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: s.divider,
      ),
    );

    return base.copyWith(
      // AppTypography nhúng sẵn màu chữ của chế độ sáng, nên bản tối phải đè lại
      // toàn bộ, nếu không chữ đen nằm trên nền đen.
      textTheme: base.textTheme.apply(
        bodyColor: s.textPrimary,
        displayColor: s.textPrimary,
      ),
      extensions: <ThemeExtension<dynamic>>[s],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Call once at app start so all `GoogleFonts` calls share the cached font.
  static Future<void> warmUpFonts() async {
    GoogleFonts.config.allowRuntimeFetching = true;
  }
}
