import 'package:flutter/material.dart';

class DelayConfigSheet extends StatefulWidget {
  const DelayConfigSheet({super.key});

  @override
  State<DelayConfigSheet> createState() => _DelayConfigSheetState();
}

class _DelayConfigSheetState extends State<DelayConfigSheet> {
  int _minutes = 0;
  int _seconds = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cài đặt Delay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tối đa 5 phút', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text('Phút', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() {
                          _minutes = i;
                          if (_minutes == 5) _seconds = 0;
                        }),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text('$i', style: TextStyle(
                              fontSize: i == _minutes ? 24 : 18,
                              fontWeight: i == _minutes ? FontWeight.bold : FontWeight.normal,
                              color: i == _minutes ? const Color(0xFF2196F3) : Colors.grey,
                            )),
                          ),
                          childCount: 6,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Column(
                  children: [
                    const Text('Giây', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      height: 120,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() {
                          if (_minutes < 5) _seconds = i;
                        }),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text(i.toString().padLeft(2, '0'), style: TextStyle(
                              fontSize: i == _seconds ? 24 : 18,
                              fontWeight: i == _seconds ? FontWeight.bold : FontWeight.normal,
                              color: i == _seconds ? const Color(0xFF2196F3) : Colors.grey,
                            )),
                          ),
                          childCount: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _minutes > 0 ? '$_minutes phút $_seconds giây' : '$_seconds giây',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_minutes == 0 && _seconds == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn thời gian > 0')));
                    return;
                  }
                  Navigator.pop(context, {'minutes': _minutes, 'seconds': _seconds});
                },
                child: const Text('Xác nhận', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
