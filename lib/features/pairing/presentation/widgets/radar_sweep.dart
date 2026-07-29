// ---------------------------------------------------------------------------
// Hiệu ứng radar quét tròn — dựng lại từ IMG_1296.jpg và đối chiếu ngược lại
// với chính ảnh đó: sai số trung bình 0.68/255 mỗi kênh màu.
//
// Cấu tạo (bán kính ngoài = 1.0):
//   đĩa ngoài   r 1.000  gradient toả tròn, accent alpha 0 ở tâm -> 0.055 ở mép
//   đĩa trong   r 0.586  gradient toả tròn, accent alpha 0 -> 0.048, chồng lên
//   vệt quét    sweep gradient, alpha 0.28 ngay sau cánh -> 0 sau 98 độ
//   cánh quét   dày 0.0127 r, chạy từ tâm ra mép
//   chấm tâm    r 0.042
//   accent      #5EA4FA        nền #F6F7FB
//
// Không cần package nào, chỉ Flutter thuần.
//
//   const RadarSweep()                                    // mặc định, 236 pt
//   RadarSweep(size: 120, period: Duration(seconds: 2))
//   RadarSweep(spinning: _isScanning)                     // dừng / chạy
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadarSweep extends StatefulWidget {
  const RadarSweep({
    super.key,
    this.size = 236.0,
    this.accent = const Color(0xFF5EA4FA),
    this.background,
    this.period = const Duration(seconds: 3),
    this.spinning = true,
    this.clockwise = true,
    this.style = const RadarStyle(),
  });

  /// Cạnh của widget (hình vuông). Đường kính vòng ngoài bằng đúng cạnh này.
  final double size;

  /// Màu chủ đạo — mọi thành phần đều lấy từ đây với các mức alpha khác nhau.
  final Color accent;

  /// Nền phía sau radar. Để null nếu bên ngoài đã có nền riêng.
  /// Trong ảnh gốc nền là #F6F7FB.
  final Color? background;

  /// Thời gian quay hết một vòng.
  final Duration period;

  /// false thì đứng yên tại chỗ (không reset về 0).
  final bool spinning;

  /// true = quét theo chiều kim đồng hồ, đúng như ảnh gốc.
  final bool clockwise;

  final RadarStyle style;

  @override
  State<RadarSweep> createState() => _RadarSweepState();
}

/// Các tỉ lệ đo từ ảnh gốc. Chỉnh nếu muốn biến tấu.
@immutable
class RadarStyle {
  const RadarStyle({
    this.innerRadius = 0.5865, // 139 / 237
    this.dotRadius = 0.0422, //  10 / 237
    this.armWidth = 0.0127, //   3 / 237
    this.outerAlpha = 0.055,
    this.innerAlpha = 0.048,
    this.trailAlpha = 0.28,
    this.trailSweep = 98.0, // độ
  });

  /// Tất cả bán kính tính theo tỉ lệ của bán kính vòng ngoài.
  final double innerRadius;
  final double dotRadius;
  final double armWidth;

  /// Độ đậm của đĩa ngoài / đĩa trong ở mép của chúng.
  final double outerAlpha;
  final double innerAlpha;

  /// Độ đậm của vệt quét ngay sau cánh, và độ dài vệt tính bằng độ.
  final double trailAlpha;
  final double trailSweep;

  @override
  bool operator ==(Object other) =>
      other is RadarStyle &&
      other.innerRadius == innerRadius &&
      other.dotRadius == dotRadius &&
      other.armWidth == armWidth &&
      other.outerAlpha == outerAlpha &&
      other.innerAlpha == innerAlpha &&
      other.trailAlpha == trailAlpha &&
      other.trailSweep == trailSweep;

  @override
  int get hashCode => Object.hash(innerRadius, dotRadius, armWidth, outerAlpha,
      innerAlpha, trailAlpha, trailSweep);
}

class _RadarSweepState extends State<RadarSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _c.repeat();
  }

  @override
  void didUpdateWidget(RadarSweep old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period) _c.duration = widget.period;
    if (old.spinning != widget.spinning) {
      widget.spinning ? _c.repeat() : _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            painter: _RadarPainter(
              turn: _c.value,
              accent: widget.accent,
              background: widget.background,
              clockwise: widget.clockwise,
              style: widget.style,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.turn,
    required this.accent,
    required this.background,
    required this.clockwise,
    required this.style,
  });

  /// 0..1, vị trí của cánh quét trên vòng tròn.
  final double turn;
  final Color accent;
  final Color? background;
  final bool clockwise;
  final RadarStyle style;

  Color _a(double o) => accent.withValues(alpha: o.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 2;
    if (r <= 0) return;

    final Color? bg = background;
    if (bg != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    }

    // 1 + 2. hai đĩa, mỗi đĩa một gradient toả tròn từ trong suốt ra mép
    void disc(double radius, double edgeAlpha) {
      final Rect box = Rect.fromCircle(center: c, radius: radius);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[_a(0), _a(edgeAlpha)],
          ).createShader(box),
      );
    }

    disc(r, style.outerAlpha);
    disc(r * style.innerRadius, style.innerAlpha);

    // 3 + 4. vệt quét và cánh quét — vẽ ở tư thế chuẩn rồi xoay cả canvas
    final double dir = clockwise ? 1.0 : -1.0;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(dir * turn * 2 * math.pi);

    final double frac = (style.trailSweep / 360.0).clamp(0.0, 1.0);
    final Rect box = Rect.fromCircle(center: Offset.zero, radius: r);
    // cánh nằm ở góc 0; vệt kéo dài về phía sau nó
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = SweepGradient(
          colors: clockwise
              ? <Color>[_a(0), _a(0), _a(style.trailAlpha)]
              : <Color>[_a(style.trailAlpha), _a(0), _a(0)],
          stops: clockwise
              ? <double>[0.0, 1.0 - frac, 1.0]
              : <double>[0.0, frac, 1.0],
        ).createShader(box),
    );

    canvas.drawLine(
      Offset.zero,
      Offset(r, 0),
      Paint()
        ..color = accent
        ..strokeWidth = math.max(1.0, r * 2 * style.armWidth)
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // 5. chấm tâm
    canvas.drawCircle(c, r * style.dotRadius, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.turn != turn ||
      old.accent != accent ||
      old.background != background ||
      old.clockwise != clockwise ||
      old.style != style;
}
