import 'package:flutter/material.dart';

class DeviceActionPage extends StatefulWidget {
  final Map<String, dynamic> device;
  const DeviceActionPage({super.key, required this.device});

  @override
  State<DeviceActionPage> createState() => _DeviceActionPageState();
}

class _DeviceActionPageState extends State<DeviceActionPage> {
  String? selectedSwitch;

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device['name'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          deviceName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: selectedSwitch != null
                ? () {
                    final result = {
                      'device': widget.device,
                      'action': {
                        'switch': selectedSwitch,
                      },
                    };
                    Navigator.of(context).pop(result);
                  }
                : null,
            child: Text(
              "Xac nhan",
              style: TextStyle(
                color: selectedSwitch != null
                    ? Colors.red
                    : Colors.red.withOpacity(0.4),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chon hanh dong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionOption(
              label: 'Mo rem',
              value: 'on',
              icon: Icons.curtains_outlined,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildActionOption(
              label: 'Dong rem',
              value: 'off',
              icon: Icons.curtains_closed_outlined,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedSwitch == value;
    return GestureDetector(
      onTap: () => setState(() => selectedSwitch = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
