import 'package:flutter/material.dart';

/// Full-page delay picker with 3 scroll wheels: hours, minutes, seconds.
/// Max delay: 5 minutes (300 seconds). Hours wheel is 0 only.
class DelayConfigPage extends StatefulWidget {
  const DelayConfigPage({super.key});

  @override
  State<DelayConfigPage> createState() => _DelayConfigPageState();
}

class _DelayConfigPageState extends State<DelayConfigPage> {
  late final FixedExtentScrollController _hoursController;
  late final FixedExtentScrollController _minutesController;
  late final FixedExtentScrollController _secondsController;

  int _hours = 0;
  int _minutes = 1;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _minutes);
    _secondsController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _onNext() {
    final totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (totalSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time > 0')),
      );
      return;
    }
    // Cap at 5 minutes
    final cappedMinutes = _minutes > 5 ? 5 : _minutes;
    final cappedSeconds = cappedMinutes >= 5 ? 0 : _seconds;
    Navigator.pop(context, {
      'minutes': cappedMinutes,
      'seconds': cappedSeconds,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Delay the action',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _onNext,
            child: const Text(
              'Next',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Picker area
          Container(
            color: Colors.white,
            height: 220,
            child: Stack(
              children: [
                // Selection highlight band
                Center(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                // Pickers
                Row(
                  children: [
                    // Hours
                    Expanded(
                      child: _buildWheel(
                        controller: _hoursController,
                        itemCount: 6, // 0-5
                        selectedValue: _hours,
                        onChanged: (i) => setState(() => _hours = i),
                      ),
                    ),
                    // "h" label
                    Text('h', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    // Minutes
                    Expanded(
                      child: _buildWheel(
                        controller: _minutesController,
                        itemCount: 60, // 0-59
                        selectedValue: _minutes,
                        onChanged: (i) => setState(() => _minutes = i),
                        padZero: true,
                      ),
                    ),
                    // "min" label
                    Text('min', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    // Seconds
                    Expanded(
                      child: _buildWheel(
                        controller: _secondsController,
                        itemCount: 60, // 0-59
                        selectedValue: _seconds,
                        onChanged: (i) => setState(() => _seconds = i),
                        padZero: true,
                      ),
                    ),
                    // "s" label
                    Text('s', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required ValueChanged<int> onChanged,
    bool padZero = false,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      perspective: 0.003,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (_, i) {
          final isSelected = i == selectedValue;
          final text = padZero ? i.toString().padLeft(2, '0') : '$i';
          return Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSelected ? 28 : 20,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}
