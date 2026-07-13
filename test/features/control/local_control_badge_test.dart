import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/control/domain/entities/transport_state.dart';
import 'package:smart_curtain_app/features/control/presentation/widgets/local_control_badge.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, TransportState transport,
      {VoidCallback? onRetry}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalControlBadge(transport: transport, onRetry: onRetry),
        ),
      ),
    );
  }

  group('LocalControlBadge', () {
    testWidgets('cloud → ẩn hoàn toàn (SizedBox.shrink)', (tester) async {
      await pumpBadge(tester, TransportState.cloud);
      expect(find.byType(LocalControlBadge), findsOneWidget);
      expect(find.text('Local control (offline)'), findsNothing);
      expect(find.text('Device unreachable'), findsNothing);
    });

    testWidgets('bleFallback → "Local control" + "Reconnecting…"',
        (tester) async {
      await pumpBadge(tester, TransportState.bleFallback);
      expect(find.text('Local control (offline)'), findsOneWidget);
      expect(find.text('Reconnecting…'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_audio), findsOneWidget);
      // Không có nút Retry trong BLE fallback
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('unreachable → "Device unreachable" + Retry button',
        (tester) async {
      var retryCount = 0;
      await pumpBadge(tester, TransportState.unreachable,
          onRetry: () => retryCount++);
      expect(find.text('Device unreachable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retryCount, 1);
    });

    testWidgets('unreachable without onRetry → không show button',
        (tester) async {
      await pumpBadge(tester, TransportState.unreachable);
      expect(find.text('Device unreachable'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
