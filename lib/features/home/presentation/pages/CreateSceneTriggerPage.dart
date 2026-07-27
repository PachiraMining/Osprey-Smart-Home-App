import 'package:smart_curtain_app/features/scene/domain/entities/schedule_condition_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/automation_detail_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/schedule_condition_page.dart';
import 'package:flutter/material.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart';

class CreateSceneTriggerPage extends StatelessWidget {
  const CreateSceneTriggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Create Scene',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Card 1: Launch Tap-to-Run
            _buildTriggerCard(
              context,
              icon: Icons.touch_app_outlined,
              iconColor: const Color(0xFFFF6B35),
              title: 'Launch Tap-to-Run',
              example: 'Example: turn off all lights in the bedroom with one tap.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTapToRunPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            // Card 2: Weather, Schedule, Device status
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Cell 1: When weather changes (chức năng làm sau)
                  _buildTriggerRow(
                    context,
                    icon: Icons.wb_sunny,
                    iconColor: const Color(0xFFFFA726),
                    title: 'When weather changes',
                    example:
                        'Example: when local temperature is greater than 28°C.',
                    onTap: () => _comingSoon(context, 'Weather trigger'),
                  ),
                  _rowDivider(),
                  // Cell 2: Schedule (đã nối luồng automation If–Then)
                  _buildTriggerRow(
                    context,
                    icon: Icons.access_time,
                    iconColor: const Color(0xFF42A5F5),
                    title: 'Schedule',
                    example: 'Example: 7:00 a.m. every morning.',
                    onTap: () async {
                      // Luồng MỚI: chọn lịch → trình soạn automation If–Then
                      // (AutomationDetailPage) với điều kiện đã điền sẵn.
                      final navigator = Navigator.of(context);
                      final condition =
                          await navigator.push<ScheduleConditionEntity>(
                        MaterialPageRoute(
                          builder: (_) => const ScheduleConditionPage(),
                        ),
                      );
                      if (condition == null) return;
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AutomationDetailPage(
                            initialCondition: condition,
                          ),
                        ),
                      );
                    },
                  ),
                  _rowDivider(),
                  // Cell 3: When device status changes (chức năng làm sau)
                  _buildTriggerRow(
                    context,
                    icon: Icons.lightbulb,
                    iconColor: const Color(0xFF2ECC71),
                    title: 'When device status changes',
                    example: 'Example: when an unusual activity is detected.',
                    onTap: () =>
                        _comingSoon(context, 'Device-status trigger'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String example,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  /// Hairline giữa các row trong cùng card (thụt lề khớp text như iOS list).
  Widget _rowDivider() => Padding(
        padding: const EdgeInsets.only(left: 64),
        child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
      );

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$label is coming soon'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildTriggerRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String example,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}
