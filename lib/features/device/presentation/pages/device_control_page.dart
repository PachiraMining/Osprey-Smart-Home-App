import 'package:flutter/material.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/send_device_command.dart';
import '../../../../core/di/injector.dart';

class DeviceControlPage extends StatefulWidget {
  final DeviceEntity device;
  const DeviceControlPage({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage>
    with TickerProviderStateMixin {
  double _position = 0.0; // 0.0 = mở, 1.0 = đóng
  bool _isRunning = false;

  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final SendDeviceCommand _sendDeviceCommand;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // INJECT USE CASE
    _sendDeviceCommand = sl<SendDeviceCommand>();

    _controller.addListener(() {
      setState(() => _position = _controller.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendCommand(String command) async {
    if (_isRunning && command != 'STOP') return;

    setState(() => _isRunning = true);
    _pulseController.repeat(reverse: true);

    try {
      print('📤 Sending $command to device ${widget.device.id}');

      // GỌI API THẬT
      final result = await _sendDeviceCommand(widget.device.id, command);

      result.fold(
        (failure) {
          // Lỗi từ API
          print('❌ API Error: ${failure.message}');
          _showSnackBar('Lỗi: ${failure.message}', Colors.red);
          _pulseController.stop();
          _pulseController.reset();
          setState(() => _isRunning = false);
        },
        (_) {
          // Thành công → Chạy animation
          print('✅ Command sent successfully');

          if (command == 'OPEN') {
            _controller.animateTo(0.0, curve: Curves.easeInOut);
            _addAutoStopListener(); // ✨ Thêm listener tự động STOP
          } else if (command == 'CLOSE') {
            _controller.animateTo(1.0, curve: Curves.easeInOut);
            _addAutoStopListener(); // ✨ Thêm listener tự động STOP
          } else if (command == 'STOP') {
            // ✨ User nhấn STOP → Dừng ngay
            _controller.stop();
            _pulseController.stop();
            _pulseController.reset();
            setState(() => _isRunning = false);
            return;
          }
        },
      );
    } catch (e) {
      print('❌ Exception: $e');
      _showSnackBar('Lỗi kết nối', Colors.red);
      _pulseController.stop();
      _pulseController.reset();
      setState(() => _isRunning = false);
    }
  }

  // ✨ HÀM MỚI: Tự động gửi STOP khi đến 0% hoặc 100%
  void _addAutoStopListener() {
    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        // Gửi lệnh STOP đến thiết bị
        print(
          '📤 Auto sending STOP (reached ${status == AnimationStatus.completed ? "100%" : "0%"})',
        );
        _sendDeviceCommand(widget.device.id, 'STOP').then((result) {
          result.fold(
            (failure) => print('❌ Auto STOP failed: ${failure.message}'),
            (_) => print('✅ Auto STOP sent successfully'),
          );
        });

        // Dọn dẹp UI
        _pulseController.stop();
        _pulseController.reset();
        setState(() => _isRunning = false);

        // ⚠️ QUAN TRỌNG: Xóa listener để tránh duplicate
        _controller.removeStatusListener(statusListener);
      }
    }

    _controller.addStatusListener(statusListener);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.device.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          // THANH RAY + MOTOR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60),
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 30 + _position * 200,
                  child: Row(
                    children: [
                      _MotorDot(active: _isRunning),
                      const SizedBox(width: 12),
                      _MotorDot(active: _isRunning),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // RÈM DỌC
          Expanded(
            child: Stack(
              children: [
                Container(color: Colors.grey.shade50),
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _position,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: VerticalCurtainPainter(),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // PHẦN TRĂM
          Text(
            '${(100 - (_position * 100)).toInt()}%',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _position == 0
                ? 'Mở hoàn toàn'
                : _position == 1
                ? 'Đóng hoàn toàn'
                : 'Đang di chuyển',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 40),

          // 3 NÚT ĐIỀU KHIỂN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onTap: () => _sendCommand('OPEN'),
                disabled: _isRunning,
              ),
              const SizedBox(width: 40),
              _SmallButton(
                icon: Icons.pause_rounded,
                onTap: () => _sendCommand('STOP'),
                disabled: false,
              ),
              const SizedBox(width: 40),
              _SmallButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: () => _sendCommand('CLOSE'),
                disabled: _isRunning,
              ),
            ],
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _MotorDot({required bool active}) {
    return AnimatedOpacity(
      opacity: active ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _SmallButton({
    required IconData icon,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: disabled ? null : onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: disabled
                ? Colors.grey.shade200
                : Colors.blue.shade50.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: disabled ? Colors.grey.shade400 : Colors.blue.shade300,
              width: 1.8,
            ),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Icon(
            icon,
            color: disabled ? Colors.grey.shade500 : Colors.blue.shade700,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class VerticalCurtainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final path = Path();
    final segments = 22;
    final waveHeight = 40.0;

    for (int i = 0; i < segments; i++) {
      double y = i * (size.height / (segments - 1));
      path.moveTo(60, y);
      path.lineTo(size.width - 60, y);

      if (i < segments - 1) {
        double nextY = (i + 1) * (size.height / (segments - 1));
        path.quadraticBezierTo(
          size.width / 2,
          y + waveHeight,
          size.width - 60,
          nextY,
        );
        path.moveTo(60, nextY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
