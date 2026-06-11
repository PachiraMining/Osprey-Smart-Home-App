import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';

/// Màn DEBUG gọi API — fire endpoint thủ công, xem **đúng** request/response.
///
/// Mục đích chính: phân biệt 2 API "gỡ bỏ thiết bị" rất dễ gọi nhầm
/// (xem [_presets]). Backend trả 200 cho cả khi gọi nhầm Nút 1 ⇄ Nút 2 nên
/// chỉ có cách xem response shape + path thực tế mới biết gọi đúng chưa.
///
/// Dùng Dio riêng với `validateStatus: (_) => true` để KHÔNG throw trên
/// 4xx/5xx — bắt trọn status + body để debug, thay vì nuốt lỗi như production.
class ApiDebugPage extends StatefulWidget {
  const ApiDebugPage({super.key});

  @override
  State<ApiDebugPage> createState() => _ApiDebugPageState();
}

/// Một preset endpoint. `note` cảnh báo lỗi thường gặp.
class _Preset {
  final String label;
  final String method;
  final String path;
  final String? note;
  final Color color;

  const _Preset({
    required this.label,
    required this.method,
    required this.path,
    this.note,
    this.color = AppColors.primary,
  });
}

/// Kết quả 1 lần gọi — bất biến, push vào history.
class _CallResult {
  final String method;
  final String url;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  final int? statusCode;
  final Map<String, String> responseHeaders;
  final String responseBody;
  final int elapsedMs;
  final String? error;

  const _CallResult({
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
    required this.statusCode,
    required this.responseHeaders,
    required this.responseBody,
    required this.elapsedMs,
    required this.error,
  });

  bool get isSuccess =>
      error == null && statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

class _ApiDebugPageState extends State<ApiDebugPage> {
  static const List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE'];

  /// Presets — 2 endpoint gỡ thiết bị + biến thể sai để test thực nghiệm.
  /// Theo note backend: Nút 1 path KHÔNG có "homes", Nút 2 CÓ "homes".
  /// App hiện tại lại gọi Nút 1 CÓ "homes" → kèm cả 2 biến thể để so kết quả.
  static const List<_Preset> _presets = [
    _Preset(
      label: 'Button 1 · Disconnect (spec: NO homes)',
      method: 'DELETE',
      path: '/api/smarthome/{homeId}/devices/{deviceId}',
      note: 'Per backend note. Response 200, no body. '
          'If 404 → backend uses path WITH "homes" (see variant below).',
      color: AppColors.warning,
    ),
    _Preset(
      label: 'Button 1 · Disconnect (current app: WITH homes)',
      method: 'DELETE',
      path: '/api/smarthome/homes/{homeId}/devices/{deviceId}',
      note: 'Path the app actually uses (home_remote_datasource.dart:164). '
          'Compare with the variant above to see which one returns 200.',
      color: AppColors.warning,
    ),
    _Preset(
      label: 'Button 2 · Unbind + wipe data (factory-reset)',
      method: 'POST',
      path: '/api/smarthome/homes/{homeId}/devices/{deviceId}/factory-reset',
      note: 'MUST include "homes" + "/factory-reset". Response MUST contain '
          'the "deviceWasOnline" field. May take ~1.5-2s — do NOT retry.',
      color: AppColors.error,
    ),
    _Preset(
      label: 'GET homes list',
      method: 'GET',
      path: '/api/smarthome/homes',
      color: AppColors.primary,
    ),
    _Preset(
      label: 'GET devices in home',
      method: 'GET',
      path: '/api/smarthome/homes/{homeId}/devices',
      color: AppColors.primary,
    ),
    // ── Khám phá dữ liệu mạng (SSID/RSSI) cho màn Device Network ──
    _Preset(
      label: 'GET device info (find SSID/RSSI)',
      method: 'GET',
      path: '/api/device/info/{deviceId}',
      note: 'Check which field contains SSID / signal / rssi. Send this raw JSON back.',
      color: AppColors.accent,
    ),
    _Preset(
      label: 'GET TB attributes (ssid/rssi?)',
      method: 'GET',
      path: '/api/plugins/telemetry/DEVICE/{deviceId}/values/attributes',
      note: 'ThingsBoard attributes. Look for ssid/rssi/signal keys. May return '
          '403/404 if the proxy is closed — report the status back.',
      color: AppColors.accent,
    ),
    _Preset(
      label: 'GET TB timeseries (telemetry)',
      method: 'GET',
      path: '/api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries',
      note: 'Latest telemetry. SSID/RSSI may live here instead of attributes.',
      color: AppColors.accent,
    ),
  ];

  String _method = 'DELETE';
  late final TextEditingController _pathCtrl;
  late final TextEditingController _homeIdCtrl;
  late final TextEditingController _deviceIdCtrl;
  late final TextEditingController _bodyCtrl;

  final List<_CallResult> _history = [];
  bool _sending = false;
  String? _activeNote;

  @override
  void initState() {
    super.initState();
    final tm = sl<TokenManager>();
    _pathCtrl = TextEditingController(text: _presets.first.path);
    _homeIdCtrl = TextEditingController(text: tm.getHomeIdSync() ?? '');
    _deviceIdCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _method = _presets.first.method;
    _activeNote = _presets.first.note;
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    _homeIdCtrl.dispose();
    _deviceIdCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(_Preset p) {
    setState(() {
      _method = p.method;
      _pathCtrl.text = p.path;
      _bodyCtrl.text = '';
      _activeNote = p.note;
    });
  }

  /// Thay `{homeId}` / `{deviceId}` bằng giá trị đã nhập.
  String _resolvedPath() {
    return _pathCtrl.text
        .replaceAll('{homeId}', _homeIdCtrl.text.trim())
        .replaceAll('{deviceId}', _deviceIdCtrl.text.trim());
  }

  Future<void> _send() async {
    if (_sending) return;

    // Chặn placeholder chưa điền → tránh path có segment rỗng kiểu
    // `.../devices//factory-reset` (backend trả 405/404 khó hiểu).
    final missing = <String>[
      if (_pathCtrl.text.contains('{homeId}') && _homeIdCtrl.text.trim().isEmpty)
        'homeId',
      if (_pathCtrl.text.contains('{deviceId}') &&
          _deviceIdCtrl.text.trim().isEmpty)
        'deviceId',
    ];
    if (missing.isNotEmpty) {
      _showSnack('Missing: ${missing.join(", ")} — path will have an empty segment');
      return;
    }

    final path = _resolvedPath();
    final token = sl<TokenManager>().getTokenSync();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['X-Authorization'] = 'Bearer $token';
    }

    dynamic body;
    String? rawBody;
    final bodyText = _bodyCtrl.text.trim();
    if ((_method == 'POST' || _method == 'PUT') && bodyText.isNotEmpty) {
      try {
        body = jsonDecode(bodyText);
        rawBody = bodyText;
      } catch (e) {
        _showSnack('Body is not valid JSON: $e');
        return;
      }
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.thingsboardBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (_) => true, // KHÔNG throw — bắt trọn mọi status
      ),
    );

    setState(() => _sending = true);
    final sw = Stopwatch()..start();
    _CallResult result;
    try {
      final resp = await dio.request(
        path,
        data: body,
        options: Options(method: _method, headers: headers),
      );
      sw.stop();
      result = _CallResult(
        method: _method,
        url: '${AppConfig.thingsboardBaseUrl}$path',
        requestHeaders: headers,
        requestBody: rawBody,
        statusCode: resp.statusCode,
        responseHeaders: _flattenHeaders(resp.headers),
        responseBody: _pretty(resp.data),
        elapsedMs: sw.elapsedMilliseconds,
        error: null,
      );
    } on DioException catch (e) {
      sw.stop();
      result = _CallResult(
        method: _method,
        url: '${AppConfig.thingsboardBaseUrl}$path',
        requestHeaders: headers,
        requestBody: rawBody,
        statusCode: e.response?.statusCode,
        responseHeaders:
            e.response != null ? _flattenHeaders(e.response!.headers) : const {},
        responseBody:
            e.response != null ? _pretty(e.response!.data) : '(no response)',
        elapsedMs: sw.elapsedMilliseconds,
        error: '${e.type.name}: ${e.message}',
      );
    } catch (e) {
      sw.stop();
      result = _CallResult(
        method: _method,
        url: '${AppConfig.thingsboardBaseUrl}$path',
        requestHeaders: headers,
        requestBody: rawBody,
        statusCode: null,
        responseHeaders: const {},
        responseBody: '',
        elapsedMs: sw.elapsedMilliseconds,
        error: e.toString(),
      );
    } finally {
      dio.close();
    }

    if (!mounted) return;
    setState(() {
      _sending = false;
      _history.insert(0, result);
    });
  }

  Map<String, String> _flattenHeaders(Headers h) =>
      {for (final e in h.map.entries) e.key: e.value.join(', ')};

  static String _pretty(dynamic data) {
    if (data == null) return '(empty body)';
    try {
      if (data is String) {
        if (data.isEmpty) return '(empty body)';
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _curl(_CallResult r) {
    final buf = StringBuffer('curl -X ${r.method} \\\n');
    r.requestHeaders.forEach((k, v) {
      buf.write("  -H '$k: $v' \\\n");
    });
    if (r.requestBody != null && r.requestBody!.isNotEmpty) {
      buf.write("  -d '${r.requestBody}' \\\n");
    }
    buf.write("  '${r.url}'");
    return buf.toString();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _copy(String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Copied $what');
  }

  // ─── UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Debug API',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => setState(_history.clear),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _presetChips(),
          const SizedBox(height: 16),
          _requestBuilder(),
          if (_activeNote != null) ...[
            const SizedBox(height: 12),
            _noteBox(_activeNote!),
          ],
          const SizedBox(height: 16),
          _sendButton(),
          const SizedBox(height: 20),
          if (_history.isNotEmpty) ...[
            const Text('Results',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final r in _history) _resultCard(r),
          ],
        ],
      ),
    );
  }

  Widget _presetChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in _presets)
          ActionChip(
            label: Text(p.label,
                style: TextStyle(
                    fontSize: 11.5,
                    color: p.color,
                    fontWeight: FontWeight.w600)),
            backgroundColor: p.color.withAlpha(20),
            side: BorderSide(color: p.color.withAlpha(70)),
            onPressed: () => _applyPreset(p),
          ),
      ],
    );
  }

  Widget _requestBuilder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _methodDropdown(),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _pathCtrl,
                  style: const TextStyle(
                      fontSize: 13, fontFamily: 'monospace'),
                  decoration: _dec('Path  (use {homeId} {deviceId})'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _homeIdCtrl,
                  style: const TextStyle(
                      fontSize: 13, fontFamily: 'monospace'),
                  decoration: _dec('homeId'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _deviceIdCtrl,
                  style: const TextStyle(
                      fontSize: 13, fontFamily: 'monospace'),
                  decoration: _dec('deviceId'),
                ),
              ),
            ],
          ),
          if (_method == 'POST' || _method == 'PUT') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              minLines: 2,
              style:
                  const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: _dec('Body (JSON, leave empty if none)'),
            ),
          ],
          const SizedBox(height: 8),
          Builder(builder: (_) {
            final resolved = _resolvedPath();
            final hasEmptySegment = resolved.contains('//');
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '→ ${AppConfig.thingsboardBaseUrl}$resolved'
                '${hasEmptySegment ? '  ⚠ empty segment' : ''}',
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight:
                        hasEmptySegment ? FontWeight.w700 : FontWeight.w400,
                    color: hasEmptySegment
                        ? AppColors.error
                        : AppColors.textMuted),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _methodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _method,
        underline: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        items: [
          for (final m in _methods)
            DropdownMenuItem(value: m, child: Text(m)),
        ],
        onChanged: (v) => setState(() => _method = v ?? _method),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: AppColors.surfaceTint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
      );

  Widget _noteBox(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withAlpha(70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(note,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _sending ? null : _send,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: _sending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send, size: 18),
        label: Text(_sending ? 'Sending...' : 'Send request'),
      ),
    );
  }

  Widget _resultCard(_CallResult r) {
    final statusColor = r.error != null
        ? AppColors.error
        : r.isSuccess
            ? AppColors.success
            : AppColors.warning;
    final statusLabel = r.statusCode?.toString() ?? 'ERR';

    // Cảnh báo gọi nhầm: factory-reset PHẢI có deviceWasOnline.
    final isFactoryReset = r.url.contains('/factory-reset');
    final hasOnlineField = r.responseBody.contains('deviceWasOnline');
    final mismatch = isFactoryReset && r.isSuccess && !hasOnlineField;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: r == _history.first,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(28),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
              const SizedBox(width: 8),
              Text(r.method,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace')),
              const Spacer(),
              Text('${r.elapsedMs} ms',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              r.url.replaceFirst(AppConfig.thingsboardBaseUrl, ''),
              style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary),
            ),
          ),
          children: [
            if (mismatch) _mismatchBanner(),
            if (r.error != null) _kvBlock('Error', r.error!, AppColors.error),
            _kvBlock('Response body', r.responseBody, AppColors.textPrimary),
            if (r.responseHeaders.isNotEmpty)
              _kvBlock(
                  'Response headers',
                  r.responseHeaders.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                  AppColors.textMuted),
            _kvBlock(
                'Request headers',
                r.requestHeaders.entries
                    .map((e) => '${e.key}: ${_maskToken(e.value)}')
                    .join('\n'),
                AppColors.textMuted),
            if (r.requestBody != null)
              _kvBlock('Request body', r.requestBody!, AppColors.textMuted),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(r.responseBody, 'response body'),
                    icon: const Icon(Icons.copy, size: 15),
                    label: const Text('Copy body',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(_curl(r), 'curl'),
                    icon: const Icon(Icons.terminal, size: 15),
                    label:
                        const Text('Copy curl', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mismatchBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withAlpha(80)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16, color: AppColors.error),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'POSSIBLE WRONG CALL: factory-reset returned 200 but WITHOUT '
              '"deviceWasOnline" → may have hit Button 1 (removeDeviceFromHome) '
              'instead of Button 2. Double-check the path.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.error, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Che bớt JWT trong header hiển thị (vẫn copy curl ra full để chạy được).
  String _maskToken(String v) {
    if (!v.startsWith('Bearer ') || v.length < 24) return v;
    return '${v.substring(0, 18)}…${v.substring(v.length - 6)}';
  }

  Widget _kvBlock(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SelectableText(
              value,
              style: TextStyle(
                  fontSize: 12, fontFamily: 'monospace', color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
