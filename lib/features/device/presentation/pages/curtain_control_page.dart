import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../../../../core/auth/token_manager.dart';
import '../../domain/entities/device_entity.dart';

class CurtainControlPage extends StatefulWidget {
  final DeviceEntity device;
  const CurtainControlPage({super.key, required this.device});

  @override
  State<CurtainControlPage> createState() => _CurtainControlPageState();
}

class _CurtainControlPageState extends State<CurtainControlPage>
    with TickerProviderStateMixin {
  static const _baseUrl = 'https://performentmarketing.ddnsgeek.com';

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();

  double _position = 0.5; // 0.0 = fully open, 1.0 = fully closed
  bool _isLoading = false;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addListener(() {
        setState(() => _position = _animController.value);
      });
    _animController.value = _position;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-Authorization': 'Bearer ${_tokenManager.getTokenSync() ?? ''}',
      };

  Future<void> _sendDpCommand({required int dpId, required dynamic value}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final url = '$_baseUrl/api/smarthome/devices/${widget.device.id}/commands';
      final body = jsonEncode({'dpId': dpId, 'value': value});
      print('📤 POST $url  Body: $body');

      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: body,
      );
      print('📡 Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar('Command sent', Colors.green);
      } else {
        _showSnackBar('Error: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      print('❌ Error: $e');
      _showSnackBar('Connection error', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onOpen() {
    _sendDpCommand(dpId: 1, value: 'open');
    _animController.animateTo(0.0, curve: Curves.easeInOut);
  }

  void _onClose() {
    _sendDpCommand(dpId: 1, value: 'close');
    _animController.animateTo(1.0, curve: Curves.easeInOut);
  }

  void _onStop() {
    _sendDpCommand(dpId: 1, value: 'stop');
    _animController.stop();
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.device.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Curtain visualization - takes most of the space
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = width * 1.15;
                    return SizedBox(
                      width: width,
                      height: height,
                      child: CustomPaint(
                        painter: _CurtainPainter(position: _position),
                        size: Size(width, height),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Open button
                _ImageControlButton(
                  asset: 'assets/icons/curtain_open.png',
                  size: 60,
                  imgSize: 30,
                  bgColor: const Color(0xFFF0F0F0),
                  onTap: _onOpen,
                ),
                // Pause/Stop button (larger, pink accent)
                _ControlButton(
                  icon: Icons.pause,
                  size: 80,
                  iconSize: 34,
                  bgColor: const Color(0xFFFCE4EC),
                  iconColor: const Color(0xFFB7727D),
                  onTap: _onStop,
                ),
                // Close button
                _ImageControlButton(
                  asset: 'assets/icons/curtain_close.png',
                  size: 60,
                  imgSize: 30,
                  bgColor: const Color(0xFFF0F0F0),
                  onTap: _onClose,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // "more >" link
          GestureDetector(
            onTap: () {
              // TODO: navigate to more settings
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'more',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade500),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

class _ImageControlButton extends StatelessWidget {
  final String asset;
  final double size;
  final double imgSize;
  final Color bgColor;
  final VoidCallback onTap;

  const _ImageControlButton({
    required this.asset,
    required this.size,
    required this.imgSize,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: imgSize,
            height: imgSize,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/// Custom painter: horizontal curtain that opens from center to sides
/// Motors at left/right ends of track, city skyline in background
class _CurtainPainter extends CustomPainter {
  final double position; // 0.0 = fully open, 1.0 = fully closed

  _CurtainPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final motorRadius = size.width * 0.06;
    final trackY = motorRadius + 4;
    final curtainTop = trackY + 8;
    final curtainBottom = size.height * 0.95;

    final leftEdge = motorRadius + 4;
    final rightEdge = size.width - motorRadius - 4;
    final totalWidth = rightEdge - leftEdge;

    // === Draw city skyline in background (visible when curtain is open) ===
    _drawSkyline(canvas, size, curtainTop, curtainBottom, leftEdge, rightEdge);

    // === Track bar ===
    final trackPaint = Paint()
      ..color = const Color(0xFFD5D5D5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(leftEdge, trackY),
      Offset(rightEdge, trackY),
      trackPaint,
    );

    // === Calculate curtain panel positions ===
    // position 1.0 = closed (panels meet in middle)
    // position 0.0 = open (panels pulled to edges)
    final halfWidth = totalWidth / 2;
    // Each panel width when fully closed = half of total
    // When opening, panels compress toward the edges
    final leftPanelRight = leftEdge + halfWidth * position;
    final rightPanelLeft = rightEdge - halfWidth * position;

    // === Draw LEFT curtain panel ===
    _drawCurtainPanel(
      canvas,
      left: leftEdge,
      right: leftPanelRight,
      top: curtainTop,
      bottom: curtainBottom,
      isLeftPanel: true,
    );

    // === Draw RIGHT curtain panel ===
    _drawCurtainPanel(
      canvas,
      left: rightPanelLeft,
      right: rightEdge,
      top: curtainTop,
      bottom: curtainBottom,
      isLeftPanel: false,
    );

    // === Motor circles move with curtain panels ===
    _drawMotor(canvas, Offset(leftPanelRight, trackY), motorRadius);
    _drawMotor(canvas, Offset(rightPanelLeft, trackY), motorRadius);
  }

  void _drawCurtainPanel(
    Canvas canvas, {
    required double left,
    required double right,
    required double top,
    required double bottom,
    required bool isLeftPanel,
  }) {
    final panelWidth = right - left;
    if (panelWidth < 3) return;

    final curtainHeight = bottom - top;

    // --- Curtain body (white fill) ---
    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // --- Vertical fold lines ---
    final foldLinePaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 1.0;

    // More folds when panel is compressed (bunched up)
    final foldCount = max(3, (panelWidth / 12).round());
    final foldSpacing = panelWidth / foldCount;

    for (int i = 1; i < foldCount; i++) {
      final x = left + foldSpacing * i;
      // Slight wave effect on fold lines
      final path = Path();
      path.moveTo(x, top);
      final segments = 8;
      final segH = curtainHeight / segments;
      for (int s = 0; s < segments; s++) {
        final amp = (s % 2 == 0 ? 1.5 : -1.5) * (panelWidth < 60 ? 0.8 : 0.4);
        path.quadraticBezierTo(
          x + amp, top + segH * s + segH / 2,
          x, top + segH * (s + 1),
        );
      }
      canvas.drawPath(path, foldLinePaint);
    }

    // --- Scalloped bottom edge ---
    final scallopCount = max(2, foldCount);
    final scallopW = panelWidth / scallopCount;
    final scallopDepth = min(10.0, panelWidth / 6);

    // White fill for scallops
    final scallopFill = Path();
    scallopFill.moveTo(left, bottom);
    for (int i = 0; i < scallopCount; i++) {
      final sx = left + scallopW * i;
      final ex = sx + scallopW;
      final mx = (sx + ex) / 2;
      scallopFill.quadraticBezierTo(mx, bottom + scallopDepth, ex, bottom);
    }
    scallopFill.lineTo(right, bottom - 1);
    scallopFill.lineTo(left, bottom - 1);
    scallopFill.close();
    canvas.drawPath(
      scallopFill,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Scallop outline
    final scallopOutline = Path();
    scallopOutline.moveTo(left, bottom);
    for (int i = 0; i < scallopCount; i++) {
      final sx = left + scallopW * i;
      final ex = sx + scallopW;
      final mx = (sx + ex) / 2;
      scallopOutline.quadraticBezierTo(mx, bottom + scallopDepth, ex, bottom);
    }
    canvas.drawPath(
      scallopOutline,
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // --- Panel border ---
    final borderPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Left side
    canvas.drawLine(Offset(left, top), Offset(left, bottom), borderPaint);
    // Right side
    canvas.drawLine(Offset(right, top), Offset(right, bottom), borderPaint);
    // Top
    canvas.drawLine(Offset(left, top), Offset(right, top), borderPaint);
  }

  void _drawSkyline(Canvas canvas, Size size, double top, double bottom,
      double leftEdge, double rightEdge) {
    final skylineColor = const Color(0xFFE8E4EE); // Light purple/gray
    final paint = Paint()
      ..color = skylineColor
      ..style = PaintingStyle.fill;

    final baseY = bottom * 0.85;
    final skyWidth = rightEdge - leftEdge;

    // Building definitions: (xFraction, widthFraction, heightFraction)
    final buildings = [
      (0.05, 0.06, 0.30),
      (0.12, 0.08, 0.45),
      (0.21, 0.05, 0.35),
      (0.27, 0.07, 0.55),
      (0.35, 0.06, 0.40),
      (0.42, 0.08, 0.65),
      (0.51, 0.06, 0.50),
      (0.58, 0.07, 0.60),
      (0.66, 0.05, 0.45),
      (0.72, 0.08, 0.70),
      (0.81, 0.06, 0.50),
      (0.88, 0.07, 0.55),
    ];

    for (final (xFrac, wFrac, hFrac) in buildings) {
      final bx = leftEdge + skyWidth * xFrac;
      final bw = skyWidth * wFrac;
      final bh = (baseY - top) * hFrac;
      canvas.drawRect(
        Rect.fromLTWH(bx, baseY - bh, bw, bh + (bottom - baseY)),
        paint,
      );
    }
  }

  void _drawMotor(Canvas canvas, Offset center, double radius) {
    // White fill circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    // Gray border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFD0D0D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Inner pink/mauve circle
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..color = const Color(0xFFB7727D)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CurtainPainter oldDelegate) =>
      oldDelegate.position != position;
}
