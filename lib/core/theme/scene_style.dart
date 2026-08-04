import 'package:flutter/material.dart';

/// Shared visual identity for Tap-to-Run scenes: the 12-color palette used by
/// the create page, the card gradient, plus the stable per-scene fallback so a
/// scene without a stored style keeps the SAME "random" color across reloads.
class SceneStyle {
  SceneStyle._();

  /// Đo từ app tham chiếu: bão hoà 36–80%, độ sáng 41–58%. Palette cũ vọt ra
  /// ngoài dải này (cam 91%, xanh chanh chói, một màu tối 18% gần như đen) nên
  /// thẻ trông gắt; 12 màu dưới đây đều nằm trong dải đó.
  static const palette = [
    Color(0xFFD25C53), Color(0xFFE98F3A), Color(0xFFD9AF43),
    Color(0xFF70C048), Color(0xFF29AD6F), Color(0xFF23AEA8),
    Color(0xFF3C94CA), Color(0xFF6458D0), Color(0xFF9B5AC6),
    Color(0xFFB8419D), Color(0xFFB97A69), Color(0xFF4A93A6),
  ];

  /// Icon cho người dùng chọn — bản ĐẶC, không phải bản viền. Nét viền mảnh đặt
  /// trên nền màu đậm bị mờ và bạc đi; glyph đặc mới ăn hình.
  ///
  /// Thứ tự khớp đúng ô-theo-ô với bảng chọn của app tham chiếu. Bốn glyph của
  /// họ không có bản tương đương trong Material nên dùng cái gần nhất: cây dừa
  /// -> ô dù biển, cặp cửa-kèm-mũi-tên -> rèm đóng / cửa phòng, và vật tròn có
  /// nắp (máy khuếch tán) -> bóng đèn.
  static const icons = [
    Icons.touch_app, Icons.curtains, Icons.beach_access,
    Icons.curtains_closed, Icons.hourglass_bottom, Icons.mail,
    Icons.local_offer, Icons.meeting_room, Icons.lightbulb,
    Icons.nightlight_round, Icons.location_on, Icons.cloudy_snowing,
    Icons.coffee, Icons.shield, Icons.wb_sunny,
    Icons.schedule, Icons.water_drop, Icons.work,
  ];

  /// Scene tạo trước đây lưu codePoint của icon bản VIỀN. Đổi sang bản đặc ngay
  /// lúc đọc để thẻ cũ đẹp lên mà không phải ghi lại gì lên server.
  static final Map<int, IconData> _outlinedToFilled = {
    Icons.download_outlined.codePoint: Icons.touch_app,
    Icons.curtains_outlined.codePoint: Icons.curtains,
    Icons.beach_access_outlined.codePoint: Icons.beach_access,
    Icons.hourglass_bottom_outlined.codePoint: Icons.hourglass_bottom,
    Icons.mail_outlined.codePoint: Icons.mail,
    Icons.local_offer_outlined.codePoint: Icons.local_offer,
    Icons.flag_outlined.codePoint: Icons.meeting_room,
    Icons.lock_outlined.codePoint: Icons.lightbulb,
    Icons.location_on_outlined.codePoint: Icons.location_on,
    Icons.cloud_outlined.codePoint: Icons.cloudy_snowing,
    Icons.coffee_outlined.codePoint: Icons.coffee,
    Icons.wb_sunny_outlined.codePoint: Icons.wb_sunny,
    Icons.schedule_outlined.codePoint: Icons.schedule,
    Icons.water_drop_outlined.codePoint: Icons.water_drop,
    Icons.work_outline.codePoint: Icons.work,
    // các icon đã bỏ khỏi bảng chọn — scene cũ vẫn phải hiện được
    Icons.download.codePoint: Icons.touch_app,
    Icons.play_arrow_rounded.codePoint: Icons.curtains_closed,
    Icons.flag.codePoint: Icons.meeting_room,
    Icons.lock.codePoint: Icons.lightbulb,
    Icons.cloud.codePoint: Icons.cloudy_snowing,
    Icons.contrast.codePoint: Icons.shield,
  };

  /// Content-based fold hash (no per-run seed) → palette pick that never
  /// changes for a given scene id.
  static Color colorFor(String seed) {
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }

  /// Nền thẻ scene: giữ nguyên tông màu, chỉ đổi độ sáng ±2% (sáng hơn ở góc
  /// trên-trái). Cách cũ trộn 15% màu trắng làm tụt bão hoà ~18% ở nửa trên nên
  /// thẻ bị đục như sữa; app tham chiếu chỉ lệch ~4% độ sáng, tông không đổi.
  static LinearGradient gradientFor(Color base) {
    final hsl = HSLColor.fromColor(base);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        hsl.withLightness((hsl.lightness + 0.02).clamp(0.0, 1.0)).toColor(),
        hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0)).toColor(),
      ],
    );
  }

  /// Decode "#RRGGBB|codePoint" → (Color, IconData); falls back to
  /// [colorFor] + a play icon when no style is stored.
  static (Color, IconData) decode(String? iconStr, String seedId) {
    final defaultColor = colorFor(seedId);
    const defaultIcon = Icons.touch_app;
    if (iconStr == null || !iconStr.contains('|')) {
      return (defaultColor, defaultIcon);
    }
    try {
      final parts = iconStr.split('|');
      final hex = parts[0].replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      final codePoint = int.parse(parts[1]);
      final icon = _outlinedToFilled[codePoint] ??
          IconData(codePoint, fontFamily: 'MaterialIcons');
      return (color, icon);
    } catch (_) {
      return (defaultColor, defaultIcon);
    }
  }
}
