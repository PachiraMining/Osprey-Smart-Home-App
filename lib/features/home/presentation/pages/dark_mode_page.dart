import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DarkModeSetting { normal, dark }

class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  bool _systemEnabled = false;
  DarkModeSetting _selected = DarkModeSetting.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // System toggle section
          Container(
            margin: const EdgeInsets.only(top: 10),
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'When enabled, the app will switch the dark mode on or off to match your system settings.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoSwitch(
                  value: _systemEnabled,
                  onChanged: (v) => setState(() => _systemEnabled = v),
                ),
              ],
            ),
          ),

          // Mode selection section
          Container(
            margin: const EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              children: [
                _buildModeItem(
                  'Normal Mode',
                  DarkModeSetting.normal,
                  enabled: !_systemEnabled,
                ),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 16,
                  color: Colors.grey.shade200,
                ),
                _buildModeItem(
                  'Dark Mode',
                  DarkModeSetting.dark,
                  enabled: !_systemEnabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeItem(String title, DarkModeSetting value, {required bool enabled}) {
    final isSelected = _selected == value;
    return GestureDetector(
      onTap: enabled
          ? () => setState(() => _selected = value)
          : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: enabled ? Colors.black87 : Colors.grey.shade400,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
