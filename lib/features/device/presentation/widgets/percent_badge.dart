// ---------------------------------------------------------------------------
// Osprey Smart Curtain Track — popup "95%".
//
// Đo từ IMG_1294.PNG (1290x2796 @3x). Số đo gốc tính bằng px của ảnh, tất cả
// đều quy về tỉ lệ theo cạnh hộp nên badge phóng to / thu nhỏ đều đúng dáng.
//
//   hộp        378 x 378 px  = 126 x 126 pt   (vuông chằn chặn)
//   bo góc      24 px        =   8 pt         (r / cạnh = 0.0635)
//   nền         #000000, đục hoàn toàn — không đổ bóng, không phủ mờ nền sau
//   chữ         #FFFFFF, cap-height 114 px, baseline cách mép trên hộp 241.5 px
//   bề rộng ô một chữ số 68 px, khoảng hở trước dấu % là 26 px
//   tâm hộp     x 644.5 / y 1311.5 trên màn hình  →  (518.5, 658.5) trong khung
//               thiết kế 1038 x 1062 của widget rèm  →  Alignment(0, 0.24)
//
// VỀ FONT: chữ trong ảnh là một font sans condensed (bụng chữ vuông, đuôi số 9
// chéo thẳng, dấu % có gạch gần như dựng đứng). Mình không xác định chắc chắn
// được tên font chỉ từ ảnh chụp, nên `fontFamily` để làm tham số — truyền font
// app bạn đang dùng vào là khớp. Nếu font đó không condensed sẵn, gọi
// `PercentBadge.letterSpacingFor(...)` để bóp chữ về đúng bề rộng ô 68/378.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Tỉ lệ đo trực tiếp từ ảnh gốc, tính theo cạnh hộp (378 px).
@immutable
class PercentBadgeMetrics {
  const PercentBadgeMetrics({
    this.cornerRadius = 0.0635, //  24   / 378
    this.capHeight = 0.3016, // 114   / 378
    this.baseline = 0.6389, // 241.5 / 378, tính từ mép trên hộp
    this.digitAdvance = 0.1799, //  68   / 378, bề rộng ô một chữ số
    this.percentGap = 0.0688, //  26   / 378, hở giữa số và dấu %
    this.percentScale = 1.0, // dấu % cùng cỡ với số
    this.capHeightRatio = 0.72, // cap-height / fontSize của font bạn dùng
  });

  final double cornerRadius;
  final double capHeight;
  final double baseline;
  final double digitAdvance;
  final double percentGap;
  final double percentScale;

  /// Cap-height chia cho fontSize của font đang dùng. Sans thông dụng rơi vào
  /// 0.70–0.73. Chỉnh nếu thấy chữ to hoặc nhỏ hơn ảnh gốc.
  final double capHeightRatio;
}

/// Popup vuông nền đen hiện phần trăm, đúng như trong app.
///
/// ```dart
/// PercentBadge(value: 95)                                  // hệt ảnh gốc
/// PercentBadge(value: 40, size: 96, fontFamily: 'Oswald')
/// ```
class PercentBadge extends StatelessWidget {
  const PercentBadge({
    super.key,
    required this.value,
    this.size = 126.0,
    this.fontFamily,
    this.fontWeight = FontWeight.w700,
    this.background = const Color(0xFF000000),
    this.foreground = const Color(0xFFFFFFFF),
    this.letterSpacing,
    this.metrics = const PercentBadgeMetrics(),
    this.showPercentSign = true,
  });

  /// 0..100. Được kẹp và làm tròn khi hiển thị.
  final double value;

  /// Cạnh hộp (logical px). 126 = đúng kích thước trong ảnh gốc.
  final double size;

  /// Font của app bạn. Null thì dùng font hệ thống.
  final String? fontFamily;
  final FontWeight fontWeight;
  final Color background;
  final Color foreground;

  /// Null = dùng nguyên khoảng cách tự nhiên của font.
  /// Muốn khớp đúng bề rộng ô 68/378 của ảnh gốc thì truyền giá trị lấy từ
  /// [letterSpacingFor].
  final double? letterSpacing;

  final PercentBadgeMetrics metrics;
  final bool showPercentSign;

  double get _fontSize => size * metrics.capHeight / metrics.capHeightRatio;

  /// Tính letterSpacing cần thiết để một chữ số rộng đúng `digitAdvance * size`
  /// như ảnh gốc, với font mà bạn truyền vào.
  ///
  /// ```dart
  /// final ls = PercentBadge.letterSpacingFor(size: 126, fontFamily: 'Inter');
  /// PercentBadge(value: 95, fontFamily: 'Inter', letterSpacing: ls);
  /// ```
  static double letterSpacingFor({
    double size = 126.0,
    String? fontFamily,
    FontWeight fontWeight = FontWeight.w700,
    PercentBadgeMetrics metrics = const PercentBadgeMetrics(),
  }) {
    final double fontSize = size * metrics.capHeight / metrics.capHeightRatio;
    final tp = TextPainter(
      text: TextSpan(
        text: '0',
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    final double natural = tp.width;
    tp.dispose();
    return size * metrics.digitAdvance - natural;
  }

  @override
  Widget build(BuildContext context) {
    final int shown = value.clamp(0, 100).round();
    final TextStyle base = TextStyle(
      fontFamily: fontFamily,
      fontSize: _fontSize,
      fontWeight: fontWeight,
      color: foreground,
      height: 1.0,
      letterSpacing: letterSpacing,
      // chữ số cùng bề rộng -> badge không giật khi số nhảy
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(size * metrics.cornerRadius),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          // đặt baseline đúng 241.5/378 tính từ mép trên hộp
          child: Baseline(
            baseline: size * metrics.baseline,
            baselineType: TextBaseline.alphabetic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text('$shown', style: base, textScaler: TextScaler.noScaling),
                if (showPercentSign) ...<Widget>[
                  SizedBox(width: size * metrics.percentGap),
                  Text(
                    '%',
                    style: base.copyWith(
                      fontSize: _fontSize * metrics.percentScale,
                      letterSpacing: 0,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ghép badge lên trên widget rèm, đúng vị trí trong ảnh gốc.
// ---------------------------------------------------------------------------

/// Tâm badge nằm ở (518.5, 658.5) trong khung thiết kế 1038 x 1062 của rèm.
const Alignment kPercentBadgeAlignment = Alignment(0.0, 0.240);

/// Badge rộng 378/1038 bề ngang khung rèm.
const double kPercentBadgeSizeFraction = 0.3642;

/// Rèm + badge phần trăm. Badge tự hiện khi [value] đang đổi rồi tự ẩn sau
/// [holdAfterChange]. Ảnh gốc chỉ có một khung hình nên phần đóng/mở theo thời
/// gian là mình chọn cho hợp lý — chỉnh thoải mái.
///
/// ```dart
/// CurtainTrackWithBadge(
///   value: _pos,
///   curtainBuilder: (v) => CurtainTrackView(value: v),
/// )
/// ```
class CurtainTrackWithBadge extends StatefulWidget {
  const CurtainTrackWithBadge({
    super.key,
    required this.value,
    required this.curtainBuilder,
    this.fontFamily,
    this.metrics = const PercentBadgeMetrics(),
    this.alwaysShowBadge = false,
    this.holdAfterChange = const Duration(milliseconds: 900),
    this.fadeDuration = const Duration(milliseconds: 180),
  });

  /// 0 = mở hết, 1 = đóng hết. Badge hiện `value * 100`.
  final double value;

  /// Trả về widget rèm, ví dụ `(v) => CurtainTrackView(value: v)`.
  final Widget Function(double value) curtainBuilder;

  final String? fontFamily;

  /// Cho phép nơi gọi chỉnh cỡ chữ / vị trí baseline mà không đụng số đo gốc.
  final PercentBadgeMetrics metrics;
  final bool alwaysShowBadge;
  final Duration holdAfterChange;
  final Duration fadeDuration;

  @override
  State<CurtainTrackWithBadge> createState() => _CurtainTrackWithBadgeState();
}

class _CurtainTrackWithBadgeState extends State<CurtainTrackWithBadge> {
  bool _visible = false;
  int _tick = 0;

  @override
  void didUpdateWidget(CurtainTrackWithBadge old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _poke();
  }

  void _poke() {
    final int mine = ++_tick;
    if (!_visible) setState(() => _visible = true);
    Future<void>.delayed(widget.holdAfterChange, () {
      if (mounted && mine == _tick) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double badge = box.hasBoundedWidth
            ? box.maxWidth * kPercentBadgeSizeFraction
            : 126.0;
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            widget.curtainBuilder(widget.value),
            Align(
              alignment: kPercentBadgeAlignment,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: (widget.alwaysShowBadge || _visible) ? 1.0 : 0.0,
                  duration: widget.fadeDuration,
                  curve: Curves.easeOut,
                  child: PercentBadge(
                    value: widget.value * 100,
                    size: badge,
                    fontFamily: widget.fontFamily,
                    metrics: widget.metrics,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
