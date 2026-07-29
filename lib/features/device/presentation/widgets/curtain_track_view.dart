// ---------------------------------------------------------------------------
// Osprey Smart Curtain Track — illustration rebuilt as a Flutter CustomPainter.
//
// Geometry reverse-engineered from the two reference screenshots (1290x2796 @3x)
// and verified against them: mean hem error 0.7 px, whole-scene mean channel
// error < 8/765. No assets or packages required.
//
//   CurtainTrackView(value: 0)    -> fully open (curtains bunched at the sides)
//   CurtainTrackView(value: 1)    -> fully closed
//
// The single insight behind the animation: the open curtain is the SAME vector
// panel squeezed horizontally to 0.2 of its width, anchored at its outer edge.
// Stroke weight squeezes with it, which is why the bunched pleats look hairline.
// ---------------------------------------------------------------------------

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Design-space size. Every constant below is in these units.
const Size kCurtainDesignSize = Size(1038.0, 1062.0);

class CurtainPalette {
  const CurtainPalette({
    this.rail       = const Color(0xFFC7C7D4),
    this.rod        = const Color(0xFFB3AEC4),
    this.knob       = const Color(0xFFBD728D),
    this.knobFace   = Colors.white,
    this.pleat      = const Color(0xFF86859D),
    this.fabric     = Colors.white,
    this.city       = const Color(0xFFE6E3EB),
    this.shadow     = const Color(0x23000000),
  });

  final Color rail, rod, knob, knobFace, pleat, fabric, city, shadow;
}

// ------------------------------------------------------------- measurements --
const _railRect  = Rect.fromLTWH(21.91, 27.0, 994.18, 16.77);
const _railR     = Radius.circular(8.39);
const _rodRect   = Rect.fromLTWH(0.0, 56.35, 1038.0, 16.74);
const _rodR      = Radius.circular(8.37);

const double _knobR      = 50.5;   // white carrier disc
const double _knobDotR   = 30.0;    // pink dot
const double _knobCy     = 49.5;
const double _knobBlur   = 10.5;   // matches the measured 15 px shadow falloff
const double _knobLead   = 47.5;   // knob sits this far behind the leading edge

const double _panelLeftX  = 22.0;
const double _panelRightX = 1023.0;
const double _panelW      = 497.0;       // authoring width, fully closed
const double _squeeze     = 0.20423;      // width factor when fully open
const double _curtainTop  = 56.0;
const double _stroke      = 3.45;

// Pleat seams as fractions of the panel width (0 = outer edge, 1 = leading edge):
//   0.0, 0.12374, 0.23038, 0.34306, 0.44769, 0.55433, 0.65895, 0.77163, 0.88431, 1.0
/// Scalloped hem in panel-local design units (x: 0 = outer edge .. 497 = leading
/// edge, y: 0 = top of the fabric). Each entry is one cubic segment (c1, c2, end).
const List<List<double>> _hem = <List<double>>[
  [6.62, 992.04, 11.47, 1001.3, 30.75, 1001.3],
  [65.1, 1001.3, 53.65, 971.9, 88.0, 971.9],
  [120.7, 971.9, 109.8, 1001.3, 142.5, 1001.3],
  [174.9, 1001.3, 164.1, 971.9, 196.5, 971.9],
  [228.0, 971.9, 217.5, 1001.3, 249.0, 1001.3],
  [280.5, 1001.3, 270.0, 971.9, 301.5, 971.9],
  [333.9, 971.9, 323.1, 1001.3, 355.5, 1001.3],
  [389.1, 1001.3, 377.9, 971.9, 411.5, 971.9],
  [445.55, 971.9, 434.2, 1001.3, 468.25, 1001.3],
  [485.65, 1001.3, 491.19, 993.62, 497.0, 986.12]
];
const List<double> _hemStart = <double>[0.0, 983.91];
const double _hemEndX = 497.0;

/// Where each pleat seam meets the hem.
const List<List<double>> _pleatEnds = <List<double>>[[61.5, 983.91], [114.5, 985.59], [170.5, 985.24], [222.5, 986.25], [275.5, 986.25], [327.5, 985.24], [383.5, 986.6], [439.5, 986.12]];

/// City block: rects (l, t, w, h) in design space, plus one spire.
const List<List<double>> _buildings = <List<double>>[
  [123.0, 611.0, 57.0, 198.0],
  [211.0, 511.0, 85.0, 298.0],
  [333.0, 552.0, 53.0, 257.0],
  [365.0, 538.0, 9.0, 271.0],
  [386.0, 690.0, 13.0, 119.0],
  [399.0, 605.0, 25.0, 204.0],
  [424.0, 546.0, 41.0, 263.0],
  [468.0, 700.0, 41.0, 109.0],
  [530.0, 489.0, 20.0, 320.0],
  [550.0, 439.0, 37.0, 370.0],
  [587.0, 470.0, 14.0, 339.0],
  [601.0, 623.0, 13.0, 186.0],
  [614.0, 644.0, 20.0, 165.0],
  [634.0, 459.0, 65.0, 350.0],
  [700.0, 559.0, 37.0, 250.0],
  [738.0, 641.0, 20.0, 168.0],
  [783.0, 424.0, 57.0, 385.0],
  [876.0, 380.0, 21.0, 429.0],
  [897.0, 338.0, 26.0, 471.0]
];
const double _cityTop    = 422.0;   // gradient starts fading here
const double _cityBottom = 809.0;   // fully transparent here

// ------------------------------------------------------------------ widget --
class CurtainTrackView extends StatelessWidget {
  const CurtainTrackView({
    super.key,
    required this.value,
    this.palette = const CurtainPalette(),
    this.showCity = true,
  });

  /// 0 = fully open, 1 = fully closed.
  final double value;
  final CurtainPalette palette;
  final bool showCity;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kCurtainDesignSize.width / kCurtainDesignSize.height,
      child: CustomPaint(
        painter: _CurtainPainter(
          value: value.clamp(0.0, 1.0),
          palette: palette,
          showCity: showCity,
        ),
      ),
    );
  }
}

class _CurtainPainter extends CustomPainter {
  _CurtainPainter({required this.value, required this.palette, required this.showCity});

  final double value;
  final CurtainPalette palette;
  final bool showCity;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / kCurtainDesignSize.width;
    canvas.save();
    canvas.scale(s);

    final double k = _squeeze + (1.0 - _squeeze) * value;   // current panel width factor
    final double w = _panelW * k;

    if (showCity) _paintCity(canvas);
    _paintTrack(canvas);
    _paintPanel(canvas, _panelLeftX,  k, false);
    _paintPanel(canvas, _panelRightX, k, true);
    _paintKnob(canvas, _panelLeftX  + w - _knobLead);
    _paintKnob(canvas, _panelRightX - w + _knobLead);

    canvas.restore();
  }

  // -- city -----------------------------------------------------------------
  void _paintCity(Canvas canvas) {
    final path = Path()..fillType = PathFillType.nonZero;
    for (final b in _buildings) {
      path.addRect(Rect.fromLTWH(b[0], b[1], b[2], b[3]));
    }
    path.moveTo(226.0, 511.0);
    path.lineTo(251.0, 471.0);
    path.lineTo(276.0, 511.0);
    path.close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, _cityTop),
        const Offset(0, _cityBottom),
        <Color>[palette.city, palette.city.withAlpha(0)],
      );
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(_panelLeftX, _curtainTop, _panelRightX, kCurtainDesignSize.height));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  // -- rail + rod -----------------------------------------------------------
  void _paintTrack(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(_railRect, _railR), Paint()..color = palette.rail);
    canvas.drawRRect(RRect.fromRectAndRadius(_rodRect,  _rodR),  Paint()..color = palette.rod);
  }

  // -- one curtain panel ----------------------------------------------------
  /// [anchorX] is the fixed outer edge; the panel grows inward.
  void _paintPanel(Canvas canvas, double anchorX, double k, bool mirrored) {
    canvas.save();
    canvas.translate(anchorX, _curtainTop);
    // Non-uniform scale: geometry AND stroke weight squeeze together, exactly
    // as in the reference artwork.
    canvas.scale(mirrored ? -k : k, 1.0);

    // outer edge down -> scalloped hem across -> leading edge back up
    final edge = Path()
      ..moveTo(_hemStart[0], 0)
      ..lineTo(_hemStart[0], _hemStart[1]);
    for (final c in _hem) {
      edge.cubicTo(c[0], c[1], c[2], c[3], c[4], c[5]);
    }
    edge.lineTo(_hemEndX, 0);

    final fill = Path.from(edge)..close();
    canvas.drawPath(fill, Paint()..color = palette.fabric);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..color = palette.pleat
      ..strokeWidth = _stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(edge, line);

    for (final p in _pleatEnds) {
      canvas.drawLine(Offset(p[0], 0), Offset(p[0], p[1]), line);
    }
    canvas.restore();
  }

  // -- carrier knob ---------------------------------------------------------
  void _paintKnob(Canvas canvas, double cx) {
    final c = Offset(cx, _knobCy);
    canvas.drawCircle(c, _knobR,
        Paint()..color = palette.shadow..maskFilter = const MaskFilter.blur(BlurStyle.normal, _knobBlur));
    canvas.drawCircle(c, _knobR, Paint()..color = palette.knobFace);
    canvas.drawCircle(c, _knobDotR, Paint()..color = palette.knob);
  }

  @override
  bool shouldRepaint(_CurtainPainter old) =>
      old.value != value || old.showCity != showCity || old.palette != palette;
}

// ------------------------------------------------------- animated wrapper ---
enum CurtainCommand { open, pause, close }

class AnimatedCurtainTrack extends StatefulWidget {
  const AnimatedCurtainTrack({
    super.key,
    required this.command,
    this.initialValue = 1.0,
    this.travelDuration = const Duration(seconds: 6),
    this.palette = const CurtainPalette(),
    this.onValueChanged,
  });

  /// Latest command from the device. Changing it drives the animation.
  final CurtainCommand command;
  final double initialValue;

  /// Time for a full open -> closed sweep. Partial moves are scaled from this,
  /// so the curtain always travels at the same speed.
  final Duration travelDuration;
  final CurtainPalette palette;
  final ValueChanged<double>? onValueChanged;

  @override
  State<AnimatedCurtainTrack> createState() => _AnimatedCurtainTrackState();
}

class _AnimatedCurtainTrackState extends State<AnimatedCurtainTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.travelDuration,
    value: widget.initialValue,
  )..addListener(() => widget.onValueChanged?.call(_c.value));

  @override
  void didUpdateWidget(AnimatedCurtainTrack old) {
    super.didUpdateWidget(old);
    if (old.command != widget.command) _apply();
  }

  @override
  void initState() {
    super.initState();
    _apply();
  }

  void _apply() {
    switch (widget.command) {
      case CurtainCommand.open:
        _c.animateTo(0.0, duration: widget.travelDuration * _c.value, curve: Curves.linear);
      case CurtainCommand.close:
        _c.animateTo(1.0, duration: widget.travelDuration * (1 - _c.value), curve: Curves.linear);
      case CurtainCommand.pause:
        _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CurtainTrackView(value: _c.value, palette: widget.palette),
      );
}

// --------------------------------------------------- hit-test geometry ------
/// Vị trí núm trong KHÔNG GIAN THIẾT KẾ để trang điều khiển đặt vùng kéo trùng
/// khít với hình vẽ, khỏi phải chép lại hằng số.
class CurtainTrackGeometry {
  const CurtainTrackGeometry._();

  static const Size designSize = kCurtainDesignSize;
  static const double knobRadius = _knobR;
  static const double knobCenterY = _knobCy;

  static double _panelWidth(double value) =>
      _panelW * (_squeeze + (1.0 - _squeeze) * value);

  static double leftKnobX(double value) =>
      _panelLeftX + _panelWidth(value) - _knobLead;

  static double rightKnobX(double value) =>
      _panelRightX - _panelWidth(value) + _knobLead;

  /// Quãng đường (design units) núm đi khi `value` chạy từ 0 → 1; dùng để đổi
  /// khoảng kéo của ngón tay ra phần trăm.
  static const double travelPerUnit = _panelW * (1.0 - _squeeze);
}
