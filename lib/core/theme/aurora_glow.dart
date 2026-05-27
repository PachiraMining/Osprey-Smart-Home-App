import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apple-Intelligence-style glow effect (powered by `tornikegomareli/Aurora`
/// SwiftUI package on iOS). Renders a transparent rim glow around the screen.
///
/// On non-iOS platforms (or if the Aurora SPM package has not yet been added
/// to the Xcode project) this falls back to an animated rim gradient that
/// pulses around the edges of the screen — visually similar to Apple's own
/// Apple Intelligence shimmer.
enum AuroraGlowStyle { subtle, standard, intense }

class AuroraGlow extends StatelessWidget {
  final AuroraGlowStyle style;

  /// When false, render nothing.
  final bool active;

  const AuroraGlow({
    super.key,
    this.style = AuroraGlowStyle.standard,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();

    if (kIsWeb || !Platform.isIOS) {
      return _FallbackRimGlow(style: style);
    }

    // Try the native Aurora platform view first; if the SPM package is not
    // installed the host view is empty and invisible, so we render the
    // fallback on top so users still see *some* shimmer.
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: UiKitView(
              viewType: 'io.dracaena.curtainai/aurora_glow',
              creationParams: <String, dynamic>{'style': style.name},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        ),
        Positioned.fill(child: _FallbackRimGlow(style: style)),
      ],
    );
  }
}

class _FallbackRimGlow extends StatefulWidget {
  final AuroraGlowStyle style;

  const _FallbackRimGlow({required this.style});

  @override
  State<_FallbackRimGlow> createState() => _FallbackRimGlowState();
}

class _FallbackRimGlowState extends State<_FallbackRimGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = switch (widget.style) {
      AuroraGlowStyle.subtle => 0.6,
      AuroraGlowStyle.standard => 1.0,
      AuroraGlowStyle.intense => 1.4,
    };
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _RimGlowPainter(
              progress: _controller.value,
              intensity: intensity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RimGlowPainter extends CustomPainter {
  final double progress;
  final double intensity;

  _RimGlowPainter({required this.progress, required this.intensity});

  // Apple-Intelligence palette: cyan → blue → purple → pink
  static const _colors = [
    Color(0xFF00C8FF), // cyan
    Color(0xFF4D9BD6), // azure
    Color(0xFF9B5DE5), // violet
    Color(0xFFFF66B3), // pink
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Path traces the screen edge — paint with stroke + blur creates a
    // rim-only glow with a clear, untinted center.
    final inset = 2.0;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(inset),
      const Radius.circular(48),
    );
    final edgePath = Path()..addRRect(rrect);

    // Outer halo: wide blurred stroke, fully outside the path.
    final outerStrokeWidth = 14.0 * intensity;
    final outerBlur = 40.0 * intensity;
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerStrokeWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(progress * 2 * math.pi),
        colors: [
          ..._colors.map((c) =>
              c.withAlpha((230 * intensity).clamp(0, 255).toInt())),
          _colors.first.withAlpha((230 * intensity).clamp(0, 255).toInt()),
        ],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, outerBlur);
    canvas.drawPath(edgePath, outerPaint);

    // Inner band: thinner, brighter, normal blur for crisper edge.
    final innerStrokeWidth = 6.0 * intensity;
    final innerBlur = 14.0 * intensity;
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStrokeWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(-progress * 2 * math.pi),
        colors: [
          ..._colors.reversed.map((c) =>
              c.withAlpha((255 * intensity).clamp(0, 255).toInt())),
          _colors.last.withAlpha((255 * intensity).clamp(0, 255).toInt()),
        ],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, innerBlur);
    canvas.drawPath(edgePath, innerPaint);
  }

  @override
  bool shouldRepaint(_RimGlowPainter old) =>
      old.progress != progress || old.intensity != intensity;
}
