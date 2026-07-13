import 'package:flutter/material.dart';

import '../../domain/entities/transport_state.dart';

/// Badge subdued "Local control" hoặc "Device unreachable" theo transport.
///
/// Silent transition (Q5 backend note): chỉ hiển thị state, KHÔNG toast.
/// Khi `cloud` → trả `SizedBox.shrink()` (ẩn).
class LocalControlBadge extends StatelessWidget {
  const LocalControlBadge({
    super.key,
    required this.transport,
    this.onRetry,
  });

  final TransportState transport;

  /// Gọi khi user nhấn nút Retry trên unreachable state.
  /// Router sẽ probe lại (cloud health + BLE in-range).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (transport) {
      case TransportState.cloud:
        return const SizedBox.shrink();

      case TransportState.bleFallback:
        return _Badge(
          icon: Icons.bluetooth_audio,
          label: 'Local control (offline)',
          subLabel: 'Reconnecting…',
          tone: _BadgeTone.muted,
        );

      case TransportState.unreachable:
        return _Badge(
          icon: Icons.signal_wifi_connected_no_internet_4,
          label: 'Device unreachable',
          subLabel: 'Check WiFi or move closer for Bluetooth.',
          tone: _BadgeTone.warning,
          trailing: onRetry == null
              ? null
              : TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
        );
    }
  }
}

enum _BadgeTone { muted, warning }

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.tone,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String subLabel;
  final _BadgeTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      _BadgeTone.muted => const Color(0xFFF2F4F7),
      _BadgeTone.warning => const Color(0xFFFEF3C7),
    };
    final fg = switch (tone) {
      _BadgeTone.muted => const Color(0xFF475467),
      _BadgeTone.warning => const Color(0xFFB54708),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
