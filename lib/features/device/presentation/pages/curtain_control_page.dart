import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';
import '../../../control/data/repositories/transport_router_impl.dart';
import '../../../control/domain/entities/transport_state.dart';
import '../../../control/domain/repositories/transport_router.dart';
import '../../../control/presentation/widgets/local_control_badge.dart';
import '../../../pairing/presentation/pages/osprey_add_device_page.dart';
import '../../domain/entities/device_entity.dart';
import 'curtain_more_settings_page.dart';
import '../widgets/curtain_track_view.dart';
import '../widgets/percent_badge.dart';
import 'device_settings_page.dart';

class CurtainControlPage extends StatefulWidget {
  final DeviceEntity device;
  const CurtainControlPage({super.key, required this.device});

  @override
  State<CurtainControlPage> createState() => _CurtainControlPageState();
}

class _CurtainControlPageState extends State<CurtainControlPage>
    with TickerProviderStateMixin {
  static const _baseUrl = AppConfig.thingsboardBaseUrl;

  final _tokenManager = GetIt.instance<TokenManager>();
  final _client = GetIt.instance<http.Client>();
  final _router = GetIt.instance<TransportRouter>();

  double _position = 0.0;
  bool _isLoading = false;
  bool _isDragging = false;
  TransportState _transport = TransportState.cloud;
  StreamSubscription<TransportState>? _transportSub;

  late final AnimationController _animController;
  final _storage = GetIt.instance<FlutterSecureStorage>();

  String get _storageKey => 'curtain_pos_${widget.device.id}';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addListener(() {
        setState(() => _position = _animController.value);
      });
    _loadSavedPosition();

    // BLE Control Fallback: theo dõi transport để show badge + route lệnh.
    _router.watchDevice(widget.device.id);
    _transport = _router.currentTransport;
    _transportSub = _router.transport$.listen((s) {
      if (mounted) setState(() => _transport = s);
    });
  }

  Future<void> _loadSavedPosition() async {
    final saved = await _storage.read(key: _storageKey);
    if (saved != null) {
      final v = double.tryParse(saved) ?? 0.0;
      setState(() {
        _position = v;
        _animController.value = v;
      });
    }
  }

  Future<void> _savePosition(double pos) async {
    await _storage.delete(key: _storageKey);
    await _storage.write(key: _storageKey, value: pos.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _transportSub?.cancel();
    _router.watchDevice(null);
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

    var fallbackToBle = false;

    try {
      // Rule A: thử cloud trước nếu transport router đang nghĩ online.
      // MQTT có TCP keep-alive 60s nên CloudHealthCubit có thể chưa kịp
      // flip xuống `down` lúc user vừa tắt WiFi → cloud HTTP fail bằng
      // SocketException trong < 1s. Fallback BLE inline.
      if (_transport == TransportState.cloud) {
        try {
          final url =
              '$_baseUrl${ApiEndpoints.deviceCommands(widget.device.id)}';
          final body = jsonEncode({'dpId': dpId, 'value': value});
          final response = await _client.post(
            Uri.parse(url),
            headers: _headers,
            body: body,
          );
          if (response.statusCode == 200) {
            // Không báo gì khi thành công — hình rèm tự chuyển động là đủ.
            return;
          }
          // Non-2xx (4xx/5xx): backend reachable, không phải lỗi mạng → show.
          _showSnackBar('Error: ${response.statusCode}', Colors.red);
          return;
        } on SocketException catch (e) {
          dev.log('[CurtainCtrl] cloud HTTP SocketException ($e) — '
              'falling back to BLE', name: 'CurtainCtrl');
          fallbackToBle = true;
        } on HttpException catch (e) {
          dev.log('[CurtainCtrl] cloud HTTP HttpException ($e) — '
              'falling back to BLE', name: 'CurtainCtrl');
          fallbackToBle = true;
        } catch (e) {
          // Catch-all cho ClientException (http package wrap SocketException
          // bên trong tùy version). Bất kỳ "không ra net" error nào → BLE.
          dev.log('[CurtainCtrl] cloud HTTP error ($e) — '
              'falling back to BLE', name: 'CurtainCtrl');
          fallbackToBle = true;
        }
      }

      // BLE path: dùng cho `bleFallback`/`unreachable` HOẶC fallback từ cloud
      // network error ở trên. Route qua TransportRouter (mã hoá AES-CCM gửi
      // qua BLE_CONTROL_CMD char `...381`).
      final cmd = _mapDpToCommand(dpId, value);
      if (cmd == null) {
        _showSnackBar('Local control does not support this action', Colors.red);
        return;
      }
      dev.log('[CurtainCtrl] BLE sendCommand: $cmd (fallback=$fallbackToBle, '
          'transport=$_transport)', name: 'CurtainCtrl');
      // Khi vừa fallback từ cloud SocketException → force BLE (skip state
      // machine vì cubit chưa kịp flip). Khi user đã ở BLE/unreachable mode
      // → đi qua sendCommand bình thường.
      final result = fallbackToBle
          ? await _router.sendCommandViaBle(
              tbDeviceId: widget.device.id, command: cmd)
          : await _router.sendCommand(
              tbDeviceId: widget.device.id, command: cmd);
      result.fold(
        (failure) {
          dev.log('[CurtainCtrl] BLE result: Left(${failure.runtimeType}) '
              '${failure.message}', name: 'CurtainCtrl');
          if (failure is ReLearnRequiredFailure) {
            _showRePairDialog();
          } else if (fallbackToBle && failure is DeviceUnreachableFailure) {
            _showSnackBar(
                'No internet and Bluetooth not in range', Colors.red);
          } else {
            _showSnackBar(failure.message, Colors.red);
          }
        },
        (_) {
          dev.log('[CurtainCtrl] BLE result: Right(ok)', name: 'CurtainCtrl');
          // Im lặng khi thành công; lỗi vẫn báo như cũ.
        },
      );
    } catch (e) {
      dev.log('[CurtainCtrl] unexpected error: $e', name: 'CurtainCtrl');
      _showSnackBar('Connection error', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// dpId=1+open/close/stop → OPEN/CLOSE/STOP, dpId=2+int → PCT:N
  static String? _mapDpToCommand(int dpId, dynamic value) {
    if (dpId == 1 && value is String) {
      final upper = value.toUpperCase();
      if (upper == 'OPEN' || upper == 'CLOSE' || upper == 'STOP') return upper;
    }
    if (dpId == 2 && value is int && value >= 0 && value <= 100) {
      return 'PCT:$value';
    }
    return null;
  }

  Future<void> _showRePairDialog() async {
    if (!mounted) return;
    final ok = await AppDialog.confirm(
      context,
      title: 'Re-pair required',
      message:
          'Local Bluetooth control needs to be re-paired with this device. '
          'This usually happens after the app data was cleared or the device '
          'was factory reset.',
      confirmText: 'Re-pair now',
      cancelText: 'Later',
    );
    if (!ok) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OspreyAddDevicePage(),
      ),
    );
  }

  void _onOpen() {
    _sendDpCommand(dpId: 1, value: 'open');
    _animController.animateTo(0.0, curve: Curves.easeInOut);
    _savePosition(0.0);
  }

  void _onClose() {
    _sendDpCommand(dpId: 1, value: 'close');
    _animController.animateTo(1.0, curve: Curves.easeInOut);
    _savePosition(1.0);
  }

  void _onStop() {
    _sendDpCommand(dpId: 1, value: 'stop');
    _animController.stop();
    _savePosition(_position);
  }

  void _onPercentChanged(double percent) {
    final intPercent = percent.round();
    final pos = intPercent / 100.0;
    _animController.animateTo(pos, curve: Curves.easeInOut);
    _sendDpCommand(dpId: 2, value: intPercent);
    _savePosition(pos);
  }

  OverlayEntry? _toastEntry;

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    _toastEntry?.remove();

    final overlay = Overlay.of(context);
    final isSuccess = color == Colors.green;

    _toastEntry = OverlayEntry(
      builder: (context) => _CurtainToast(
        message: msg,
        isSuccess: isSuccess,
        onDismiss: () {
          _toastEntry?.remove();
          _toastEntry = null;
        },
      ),
    );
    overlay.insert(_toastEntry!);
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
            // Bút kèm gạch chân — thay icon bánh răng cũ.
            icon: const Icon(Icons.drive_file_rename_outline,
                size: 23, color: Colors.black87),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeviceSettingsPage(device: widget.device),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // BLE Control Fallback — badge subdued khi cloud-down (silent).
          LocalControlBadge(
            transport: _transport,
            onRetry: _transport == TransportState.unreachable
                ? () => _router.watchDevice(widget.device.id)
                : null,
          ),
          // Curtain visualization — draggable motors on track
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // Quy đổi design-space → pixel; mọi toạ độ núm lấy từ
                    // CurtainTrackGeometry nên vùng kéo luôn trùng hình vẽ.
                    final scale = width / CurtainTrackGeometry.designSize.width;
                    final height =
                        CurtainTrackGeometry.designSize.height * scale;
                    final knobRadius =
                        CurtainTrackGeometry.knobRadius * scale;
                    final knobCenterY =
                        CurtainTrackGeometry.knobCenterY * scale;
                    final travelPx =
                        CurtainTrackGeometry.travelPerUnit * scale;

                    final leftKnobX =
                        CurtainTrackGeometry.leftKnobX(_position) * scale;
                    final rightKnobX =
                        CurtainTrackGeometry.rightKnobX(_position) * scale;

                    void drag(double deltaPx) {
                      final newPos =
                          (_position + deltaPx / travelPx).clamp(0.0, 1.0);
                      setState(() {
                        _position = newPos;
                        _animController.value = newPos;
                      });
                    }

                    Widget knobHit(double centerX, bool isLeft) => Positioned(
                          left: centerX - knobRadius - 6,
                          top: knobCenterY - knobRadius - 6,
                          child: GestureDetector(
                            onHorizontalDragStart: (_) =>
                                setState(() => _isDragging = true),
                            // Núm phải kéo NGƯỢC chiều nhau: kéo sang phải là
                            // đóng với núm trái, mở với núm phải.
                            onHorizontalDragUpdate: (d) =>
                                drag(isLeft ? d.delta.dx : -d.delta.dx),
                            onHorizontalDragEnd: (_) {
                              _onPercentChanged(_position * 100);
                              setState(() => _isDragging = false);
                            },
                            child: Container(
                              width: (knobRadius + 6) * 2,
                              height: (knobRadius + 6) * 2,
                              color: Colors.transparent,
                            ),
                          ),
                        );

                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            // Badge % tự hiện khi vị trí đổi (kéo núm hoặc
                            // rèm đang chạy) rồi tự ẩn — IgnorePointer nên
                            // không chắn thao tác kéo.
                            child: CurtainTrackWithBadge(
                              value: _position,
                              curtainBuilder: (v) => CurtainTrackView(value: v),
                              // Chữ nhỏ còn 2/3 số đo gốc (0.3016 → 0.2011);
                              // baseline dời theo để chữ vẫn nằm giữa hộp, nhờ
                              // vậy lề quanh chữ rộng ra.
                              metrics: const PercentBadgeMetrics(
                                capHeight: 0.2011,
                                baseline: 0.589,
                              ),
                            ),
                          ),
                          knobHit(leftKnobX, true),
                          knobHit(rightKnobX, false),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Percentage — only visible while dragging
          AnimatedOpacity(
            opacity: _isDragging ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${(_position * 100).round()}%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB7727D),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Control buttons — kéo lên 30px trên trục Y; dùng translate nên chỉ
          // hàng nút dịch, các phần khác giữ nguyên vị trí.
          Transform.translate(
            offset: const Offset(0, -80),
            child: Padding(
              // Thu hẹp lề ngang để hai nút bên dạt ra xa nút giữa.
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImageControlButton(
                    asset: 'assets/icons/curtain_open.png',
                    size: 60,
                    imgSize: 30,
                    bgColor: const Color(0xFFF0F0F0),
                    onTap: _onOpen,
                  ),
                  _ControlButton(
                    icon: Icons.pause,
                    size: 80,
                    iconSize: 34,
                    // Hồng nhạt hơn một bậc so với 0xFFFCE4EC.
                    bgColor: const Color(0xFFFDF0F4),
                    iconColor: const Color(0xFFB7727D),
                    onTap: _onStop,
                  ),
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
          ),

          const SizedBox(height: 30),

          // "more >" link → màn Setting (Motor Direction, Schedule).
          // Kéo lên 10px; chữ đậm hơn cho bớt mảnh.
          Transform.translate(
            offset: const Offset(0, -10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CurtainMoreSettingsPage(
                  deviceId: widget.device.id,
                  deviceName: widget.device.name,
                ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'more',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      size: 21, color: Colors.grey.shade600),
                ],
              ),
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
class _CurtainToast extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _CurtainToast({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_CurtainToast> createState() => _CurtainToastState();
}

class _CurtainToastState extends State<_CurtainToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(_fadeAnim);

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 40,
      right: 40,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isSuccess
                    ? const Color(0xFFFCE4EC)
                    : const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB7727D).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: const Color(0xFFB7727D),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Color(0xFFB7727D),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
