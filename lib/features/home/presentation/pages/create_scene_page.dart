import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/add_task_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/home_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_state.dart';

class CreateScenePage extends StatefulWidget {
  final Map<String, dynamic>? scheduleData;
  const CreateScenePage({super.key, this.scheduleData});

  @override
  State<CreateScenePage> createState() => _CreateScenePageState();
}

class _CreateScenePageState extends State<CreateScenePage> {
  late String displayTitle;
  late String displaySubtitle;
  final List<Map<String, dynamic>> _thenActions = [];

  @override
  void initState() {
    super.initState();
    _processScheduleData();
  }

  void _processScheduleData() {
    if (widget.scheduleData == null) {
      displayTitle = "Chua chon dieu kien";
      displaySubtitle = "";
      return;
    }

    final data = widget.scheduleData!;
    final type = data['type'] as String;
    final time = data['time'] as TimeOfDay?;
    final repeat = data['repeat'] as String? ?? "Chi mot lan";

    if (type == "Mat troi moc") {
      displayTitle = "Mat troi moc";
      displaySubtitle = repeat;
    } else if (type == "Hoang hon") {
      displayTitle = "Hoang hon";
      displaySubtitle = repeat;
    } else {
      final hour = time?.hour.toString().padLeft(2, '0') ?? '--';
      final minute = time?.minute.toString().padLeft(2, '0') ?? '--';
      displayTitle = "Lich trinh : $hour:$minute";
      displaySubtitle = repeat;
    }
  }

  String _getTimeString() {
    final time = widget.scheduleData?['time'] as TimeOfDay?;
    if (time == null) return '00:00';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getRepeatMode() {
    final repeat = widget.scheduleData?['repeat'] as String? ?? 'Chỉ một lần';
    switch (repeat) {
      case 'Chỉ một lần':
        return 'once';
      case 'Hằng ngày':
        return 'daily';
      case 'Thứ 2 đến Thứ 6':
      case 'Cuối tuần':
      case 'Tùy chỉnh...':
        return 'weekly';
      default:
        return 'once';
    }
  }

  String _getDaysOfWeek() {
    final repeat = widget.scheduleData?['repeat'] as String? ?? 'Chỉ một lần';
    switch (repeat) {
      case 'Chỉ một lần':
        final today = DateTime.now().weekday;
        return '$today';
      case 'Hằng ngày':
        return '1,2,3,4,5,6,7';
      case 'Thứ 2 đến Thứ 6':
        return '1,2,3,4,5';
      case 'Cuối tuần':
        return '6,7';
      default:
        return '1,2,3,4,5,6,7';
    }
  }

  String _getAction() {
    if (_thenActions.isEmpty) return 'on';
    final action = _thenActions.first['action'] as Map<String, dynamic>?;
    if (action == null) return 'on';
    final switchVal = action['switch'] as String?;
    if (switchVal == 'off') return 'off';
    return 'on';
  }

  String _getDeviceId() {
    if (_thenActions.isEmpty) return '';
    final device = _thenActions.first['device'];
    if (device is Map) {
      return device['id']?.toString() ?? '';
    }
    return '';
  }

  void _showNameDialogAndSave() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            "Scene Name",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Nhap ten",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Huy bo",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final deviceId = _getDeviceId();
              if (deviceId.isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui long chon thiet bi')),
                );
                return;
              }

              // Create scene via BLoC
              context.read<SceneBloc>().add(CreateSceneEvent(
                deviceId: deviceId,
                name: name,
                action: _getAction(),
                time: _getTimeString(),
                daysOfWeek: _getDaysOfWeek(),
                repeatMode: _getRepeatMode(),
              ));

              // Close dialog
              Navigator.pop(context);

              // Show loading then navigate back
              _showCreatingAndNavigateBack(name);
            },
            child: const Text(
              "Xac nhan",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatingAndNavigateBack(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocListener<SceneBloc, SceneState>(
        listener: (context, state) {
          if (state is SceneCreated || state is SceneLoaded) {
            Navigator.pop(context); // Close loading dialog
            Navigator.pop(context); // Close CreateScenePage
            // Switch to automation tab
            Future.delayed(const Duration(milliseconds: 200), () {
              final homeState = HomePageState.globalKey.currentState;
              if (homeState != null && homeState.mounted) {
                homeState.setState(() => homeState.currentIndex = 1);
              }
            });
          } else if (state is SceneError) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Loi: ${state.message}')),
            );
          }
        },
        child: const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Dang tao scene...'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Huy bo",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          "Tao Ngu canh thong minh",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSection(
              title: "If",
              subtitle: "Khi bat ky dieu kien nao duoc dap ung",
              addButtonColor: Colors.red,
              child: _buildConditionItem(
                icon: Icons.access_time,
                iconColor: Colors.blue,
                title: displayTitle,
                subtitle: displaySubtitle,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: "Then",
              addButtonColor: Colors.red,
              child: _thenActions.isEmpty
                  ? _buildAddTaskPlaceholder()
                  : Column(
                      children: _thenActions.map(_buildActionItem).toList(),
                    ),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskPage()),
                );
                if (result is Map<String, dynamic>) {
                  setState(() => _thenActions.add(result));
                }
              },
            ),
            const SizedBox(height: 20),
            _buildOptionRow(
              title: "Precondition",
              value: "Ca ngay",
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildOptionRow(title: "Display Area", onTap: () {}),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _thenActions.isEmpty ? null : _showNameDialogAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Luu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    final device = action['device'] as Map<String, dynamic>;
    final act = action['action'] as Map<String, dynamic>;
    final deviceName = device['name']?.toString() ?? 'Unknown';
    final isOffline = device['status'] == "Ngoai tuyen" || device['status'] == 'offline';

    String actionText = "";
    if (act['switch'] == 'on')
      actionText = "Switch : On";
    else if (act['switch'] == 'off')
      actionText = "Switch : Off";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.curtains_outlined,
            size: 32,
            color: isOffline ? Colors.grey : Colors.orange[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$deviceName${isOffline ? " | Offline" : ""}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isOffline ? Colors.orange[700] : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Color addButtonColor,
    required Widget child,
    VoidCallback? onAddPressed,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 36,
            height: 36,
            child: FloatingActionButton(
              heroTag: title,
              backgroundColor: addButtonColor,
              mini: true,
              onPressed:
                  onAddPressed ??
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTaskPage()),
                  ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 12),
      ] else
        const SizedBox(height: 12),
      child,
    ],
  );

  Widget _buildConditionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    ),
  );

  Widget _buildAddTaskPlaceholder() => Container(
    padding: const EdgeInsets.symmetric(vertical: 40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Center(
      child: Text(
        "Them tac vu",
        style: TextStyle(color: Colors.grey[400], fontSize: 16),
      ),
    ),
  );

  Widget _buildOptionRow({
    required String title,
    String? value,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (value != null)
            Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}
