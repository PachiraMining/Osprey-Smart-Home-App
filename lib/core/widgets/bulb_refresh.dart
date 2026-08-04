//
//  bulb_refresh.dart
//
//  Hiệu ứng pull-to-refresh hình bóng đèn, dựng lại từ 6 frame IMG_1415…IMG_1420.
//
//  Hình bóng đèn là MỘT nét liền duy nhất, vẽ dần theo lực kéo:
//     chân cổ trái → lên vòng tròn theo chiều kim đồng hồ → xuống cổ phải
//     → sang trái theo cạnh trên nghiêng → xuống thành trái → qua đáy
//     → lên thành phải, khép lại.
//  Đúng thứ tự đó đọc ra từ ảnh hiệu (diff) giữa các frame liên tiếp.
//
//  Lúc đang tải: hình giữ nguyên ở độ mờ thấp, một đoạn nét sáng chạy vòng
//  quanh đúng đường vẽ đó, lặp vô hạn.
//
//  Dùng:
//     BulbRefresh(
//       onRefresh: () async { await api.reload(); },
//       child: ListView(children: [...]),
//     )
//

import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart' show HapticFeedback;

// ---------------------------------------------------------------------------
// Hình học
// ---------------------------------------------------------------------------

/// Số đo hình bóng đèn, tất cả là **tỉ lệ theo bán kính bầu đèn R**, gốc toạ độ
/// đặt ở tâm bầu đèn, trục y hướng xuống.
///
/// Đo từ frame cuối (IMG_1420) bằng fit Nelder-Mead trên độ phủ pixel:
/// sai số trung bình 0.017 (thang 0…1). Xem README để biết cách đo.
class BulbGeometry {
  const BulbGeometry._();

  /// Bề dày nét.
  static const double stroke = 0.15695;

  /// Nửa bề rộng cổ đèn — cũng là nửa bề rộng phần đuôi.
  static const double neckX = 0.49237;

  /// Đáy cổ trái = **điểm bắt đầu** của nét vẽ.
  static const double neckBottom = 1.18110;

  /// Cạnh trên của đuôi, đầu bên phải (thấp hơn đầu bên trái → cạnh nghiêng 8.1°).
  static const double baseTopRight = 1.14998;

  /// Cạnh trên của đuôi, đầu bên trái.
  static const double baseTopLeft = 1.28994;

  /// Đáy đuôi.
  static const double baseBottom = 1.72681;

  /// Bo góc hai góc dưới của đuôi.
  static const double baseCorner = 0.10475;

  /// y của chỗ cổ gặp bầu đèn — suy ra, không phải số đo riêng.
  static double get neckTopY => math.sqrt(1 - neckX * neckX); // 0.87039

  /// Góc (radian) của điểm cổ gặp bầu đèn, tính từ trục +x, chiều dương = theo
  /// kim đồng hồ trên màn hình. Khe hở dưới đáy bầu đèn rộng 180° − 2φ ≈ 59.0°.
  static double get phi => math.atan2(neckTopY, neckX); // 60.504°

  /// Khung bao (đã tính cả bề dày nét), theo R.
  static const double halfWidth = 1 + stroke / 2; // 1.078475
  static const double topY = -halfWidth;
  static const double bottomY = baseBottom + stroke / 2; // 1.805285

  /// rộng / cao của khung bao.
  static const double aspectRatio =
      (2 * halfWidth) / (bottomY - topY); // 0.747964

  /// Tổng chiều dài đường vẽ, theo R (dùng để canh nhịp, không bắt buộc).
  static const double pathLength = 8.7469;

  /// Dựng đường vẽ với bán kính bầu đèn [r], tâm bầu đèn ở gốc toạ độ.
  ///
  /// Đường đi đúng thứ tự hoạt hình, nên `PathMetric.extractPath(0, t * length)`
  /// cho ra đúng từng frame.
  static Path buildPath(double r) {
    final double nx = neckX * r;
    final double ny = neckTopY * r;
    final double bot = baseBottom * r;
    final double rc = baseCorner * r;
    final double p = phi;

    final Path path = Path()
      // 1. cổ trái, vẽ từ dưới lên
      ..moveTo(-nx, neckBottom * r)
      ..lineTo(-nx, ny);

    // 2. bầu đèn — cung tròn theo chiều kim đồng hồ, từ dưới-trái vòng lên rồi
    //    xuống dưới-phải. Bắt đầu ở π − φ, quét π + 2φ.
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: r),
      math.pi - p,
      math.pi + 2 * p,
      false,
    );

    // 3. xuống cổ phải, 4. sang trái theo cạnh trên nghiêng
    path
      ..lineTo(nx, baseTopRight * r)
      ..lineTo(-nx, baseTopLeft * r)
      // 5. xuống thành trái
      ..lineTo(-nx, bot - rc);

    // 6. bo góc dưới-trái rồi chạy sang phải theo đáy
    path
      ..arcTo(
        Rect.fromCircle(center: Offset(-nx + rc, bot - rc), radius: rc),
        math.pi,
        -math.pi / 2,
        false,
      )
      ..lineTo(nx - rc, bot)
      // 7. bo góc dưới-phải rồi lên thành phải, khép lại
      ..arcTo(
        Rect.fromCircle(center: Offset(nx - rc, bot - rc), radius: rc),
        math.pi / 2,
        -math.pi / 2,
        false,
      )
      ..lineTo(nx, baseTopRight * r);

    return path;
  }

  /// Bán kính bầu đèn lớn nhất vừa trong khung [size].
  static double radiusFor(Size size) => math.min(
        size.width / (2 * halfWidth),
        size.height / (bottomY - topY),
      );

  /// Tâm bầu đèn khi căn giữa hình trong khung [size].
  static Offset centerFor(Size size, double r) => Offset(
        size.width / 2,
        size.height / 2 - (topY + bottomY) / 2 * r,
      );
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

/// Vẽ bóng đèn ở một trạng thái bất kỳ.
///
/// * [progress] 0→1: vẽ dần nét theo lực kéo.
/// * [loading] 0→1: chuyển sang trạng thái đang tải (hình mờ đi, đoạn nét sáng
///   chạy vòng quanh hiện ra). Cross-fade nên chuyển tiếp không giật.
/// * [chase] 0→1: pha của đoạn nét chạy, lặp lại.
class BulbPainter extends CustomPainter {
  BulbPainter({
    required this.progress,
    required this.loading,
    required this.chase,
    this.color = const Color(0xFF9E9E9E),
    this.trackOpacity = 0.22,
    this.tailFraction = 0.28,
    this.tailSteps = 10,
    this.strokeScale = 1.0,
  });

  final double progress;
  final double loading;
  final double chase;
  final Color color;

  /// Độ mờ của hình nền lúc đang tải.
  final double trackOpacity;

  /// Chiều dài đoạn nét chạy, theo tỉ lệ tổng chiều dài đường vẽ.
  final double tailFraction;

  /// Số khúc chia để làm đuôi sao băng mờ dần.
  final int tailSteps;

  /// Nhân thêm vào bề dày nét, phòng khi muốn đậm/mảnh hơn số đo gốc.
  final double strokeScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final double r = BulbGeometry.radiusFor(size);
    if (r <= 0) return;
    final Offset c = BulbGeometry.centerFor(size, r);

    canvas.save();
    canvas.translate(c.dx, c.dy);

    final Path path = BulbGeometry.buildPath(r);
    final PathMetric metric = path.computeMetrics().first;
    final double len = metric.length;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = BulbGeometry.stroke * r * strokeScale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // --- hình nền: phần đã vẽ, mờ dần đi khi chuyển sang trạng thái tải ------
    final double drawn = (progress.clamp(0.0, 1.0)) * len;
    if (drawn > 0.01) {
      final double a = 1.0 - (1.0 - trackOpacity) * loading.clamp(0.0, 1.0);
      canvas.drawPath(
        metric.extractPath(0, drawn),
        paint..color = color.withValues(alpha: color.a * a),
      );
    }

    // --- đoạn nét chạy vòng quanh -------------------------------------------
    if (loading > 0.001) {
      final double head = (chase % 1.0) * len;
      final double tail = tailFraction.clamp(0.02, 0.9) * len;
      final int steps = math.max(2, tailSteps);
      for (int i = 0; i < steps; i++) {
        final double t1 = head - tail * i / steps;
        final double t0 = head - tail * (i + 1) / steps;
        // đoạn đầu sáng hết, phần đuôi nhạt dần
        final double f = math.min(1.0, (1.0 - i / steps) * 1.6);
        paint
          ..color = color.withValues(
              alpha: (color.a * f * loading).clamp(0.0, 1.0))
          ..strokeCap = i == 0 ? StrokeCap.round : StrokeCap.butt;
        _drawWrapped(canvas, metric, t0, t1, len, paint);
      }
    }

    canvas.restore();
  }

  /// Vẽ đoạn [from]…[to] trên đường, tự nối vòng khi chạy quá đầu/cuối.
  static void _drawWrapped(Canvas canvas, PathMetric m, double from, double to,
      double len, Paint paint) {
    double a = from % len;
    double b = to % len;
    if (a < 0) a += len;
    if (b < 0) b += len;
    if (b >= a) {
      canvas.drawPath(m.extractPath(a, b), paint);
    } else {
      canvas.drawPath(m.extractPath(a, len), paint);
      canvas.drawPath(m.extractPath(0, b), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BulbPainter old) =>
      old.progress != progress ||
      old.loading != loading ||
      old.chase != chase ||
      old.color != color ||
      old.trackOpacity != trackOpacity ||
      old.tailFraction != tailFraction ||
      old.tailSteps != tailSteps ||
      old.strokeScale != strokeScale;
}

// ---------------------------------------------------------------------------
// Widget rời — dùng được ngoài pull-to-refresh
// ---------------------------------------------------------------------------

/// Bóng đèn tự chạy: vẽ vào một lần rồi để đoạn nét chạy vòng quanh mãi.
/// Hợp cho màn hình trống đang tải.
class BulbSpinner extends StatefulWidget {
  const BulbSpinner({
    super.key,
    this.height = 34,
    this.color = const Color(0xFF9E9E9E),
    this.drawDuration = const Duration(milliseconds: 900),
    this.chaseDuration = const Duration(milliseconds: 1100),
  });

  final double height;
  final Color color;
  final Duration drawDuration;
  final Duration chaseDuration;

  @override
  State<BulbSpinner> createState() => _BulbSpinnerState();
}

class _BulbSpinnerState extends State<BulbSpinner>
    with TickerProviderStateMixin {
  late final AnimationController _draw =
      AnimationController(vsync: this, duration: widget.drawDuration)..forward();
  late final AnimationController _chase =
      AnimationController(vsync: this, duration: widget.chaseDuration)..repeat();

  @override
  void dispose() {
    _draw.dispose();
    _chase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.height * BulbGeometry.aspectRatio,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_draw, _chase]),
        builder: (_, __) {
          final double d = Curves.easeInOut.transform(_draw.value);
          return CustomPaint(
            painter: BulbPainter(
              progress: d,
              loading: Curves.easeIn.transform(_draw.value),
              chase: _chase.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pull to refresh
// ---------------------------------------------------------------------------

enum _Mode { idle, pulling, refreshing, finishing }

/// Bọc quanh một widget cuộn bất kỳ (ListView, GridView, SingleChildScrollView…)
/// để có pull-to-refresh hình bóng đèn.
///
/// Widget tự đặt [BouncingScrollPhysics] cho con và tắt hiệu ứng loé sáng của
/// Android, để lực kéo đọc thẳng từ vị trí cuộn — không cần bám vào chi tiết
/// của gesture, nên hoạt động giống nhau trên cả hai nền tảng.
class BulbRefresh extends StatefulWidget {
  const BulbRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 92,
    this.indicatorExtent = 68,
    this.iconHeight = 34,
    this.color = const Color(0xFF9E9E9E),
    this.trackOpacity = 0.22,
    this.chaseDuration = const Duration(milliseconds: 1100),
    this.settleDuration = const Duration(milliseconds: 240),
    this.drawCurve = Curves.easeOut,
    this.hapticFeedback = true,
    this.applyPhysics = true,
  });

  /// Gọi khi người dùng kéo đủ rồi thả. Hiệu ứng chạy tới khi Future hoàn tất.
  final Future<void> Function() onRefresh;

  /// Widget cuộn nằm bên trong.
  final Widget child;

  /// Kéo quá khoảng này (px) thì hình vẽ xong và thả tay sẽ kích hoạt tải lại.
  final double triggerDistance;

  /// Khoảng trống giữ lại ở trên trong lúc đang tải.
  final double indicatorExtent;

  /// Chiều cao hình bóng đèn.
  final double iconHeight;

  final Color color;
  final double trackOpacity;
  final Duration chaseDuration;
  final Duration settleDuration;

  /// Ánh xạ lực kéo → tiến trình vẽ. `Curves.linear` cho cảm giác bám tay nhất.
  final Curve drawCurve;

  final bool hapticFeedback;

  /// Đặt false nếu bạn muốn tự quản physics của widget con.
  final bool applyPhysics;

  @override
  State<BulbRefresh> createState() => _BulbRefreshState();
}

class _BulbRefreshState extends State<BulbRefresh>
    with TickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.settleDuration,
  );
  late final AnimationController _chase = AnimationController(
    vsync: this,
    duration: widget.chaseDuration,
  );

  double _pull = 0;
  bool _armed = false;
  _Mode _mode = _Mode.idle;

  @override
  void dispose() {
    _hold.dispose();
    _chase.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;

    // Lực kéo đọc thẳng từ vị trí cuộn, kể cả lúc đang tải — nhờ vậy khi thả
    // tay hình co lại mượt theo lò xo của physics thay vì đứng khựng.
    final double pull = n.metrics.pixels < 0 ? -n.metrics.pixels : 0.0;
    if (pull != _pull) setState(() => _pull = pull);

    if (_mode == _Mode.idle || _mode == _Mode.pulling) {
      _mode = pull > 0 ? _Mode.pulling : _Mode.idle;
      if (pull >= widget.triggerDistance) {
        if (!_armed) {
          _armed = true;
          if (widget.hapticFeedback) HapticFeedback.mediumImpact();
        }
      } else if (pull <= 0) {
        // kéo quá ngưỡng rồi lại đẩy về đỉnh → huỷ, thả tay không tải lại
        _armed = false;
      }
      // Bắt đúng lúc nhấc ngón tay. ScrollEndNotification đến muộn hơn (sau khi
      // lò xo chạy xong) nên lúc đó lực kéo đã về 0.
      final bool released =
          n is UserScrollNotification && n.direction == ScrollDirection.idle;
      if (released && _armed) _startRefresh();
    }
    return false;
  }

  Future<void> _startRefresh() async {
    if (_mode == _Mode.refreshing || _mode == _Mode.finishing) return;
    setState(() => _mode = _Mode.refreshing);
    _chase.repeat();
    _hold.forward();
    Object? error;
    StackTrace? stack;
    try {
      await widget.onRefresh();
    } catch (e, s) {
      error = e;
      stack = s;
    }
    if (mounted) {
      setState(() => _mode = _Mode.finishing);
      await _hold.reverse();
      _chase.stop();
      if (mounted) {
        setState(() {
          _mode = _Mode.idle;
          _armed = false;
          _pull = 0;
        });
      }
    }
    if (error != null) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'bulb_refresh',
        context: ErrorDescription('trong khi chạy onRefresh của BulbRefresh'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.applyPhysics
        ? ScrollConfiguration(
            behavior: const _BouncyNoGlow(),
            child: widget.child,
          )
        : widget.child;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_hold, _chase]),
        builder: (BuildContext context, Widget? c) {
          final double holdPx = _hold.value * widget.indicatorExtent;
          final double extent = math.max(_pull, holdPx);
          final bool busy =
              _mode == _Mode.refreshing || _mode == _Mode.finishing;
          final double progress = busy
              ? 1.0
              : widget.drawCurve
                  .transform((_pull / widget.triggerDistance).clamp(0.0, 1.0));

          return ClipRect(
            child: Stack(
              children: <Widget>[
                // Hình vẽ nằm dưới, lộ ra trong khoảng trống phía trên.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: SizedBox(
                      height: extent,
                      child: OverflowBox(
                        alignment: Alignment.center,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: SizedBox(
                          width: widget.iconHeight * BulbGeometry.aspectRatio,
                          height: widget.iconHeight,
                          child: CustomPaint(
                            painter: BulbPainter(
                              progress: progress,
                              loading: _hold.value,
                              chase: _chase.value,
                              color: widget.color,
                              trackOpacity: widget.trackOpacity,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Nội dung: lúc kéo thì tự trôi xuống theo physics, lúc đang
                // tải thì đẩy thêm cho đủ chỗ giữ hình.
                Transform.translate(
                  offset: Offset(0, math.max(0, holdPx - _pull)),
                  child: c,
                ),
              ],
            ),
          );
        },
        child: child,
      ),
    );
  }
}

/// Cuộn kiểu iOS trên mọi nền tảng, bỏ hiệu ứng loé sáng của Android.
class _BouncyNoGlow extends ScrollBehavior {
  const _BouncyNoGlow();

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
}
