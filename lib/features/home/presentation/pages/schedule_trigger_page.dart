// lib/screens/schedule_trigger_page.dart
import 'package:flutter/material.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/create_scene_page.dart';

class ScheduleTriggerPage extends StatefulWidget {
  const ScheduleTriggerPage({super.key});

  @override
  State<ScheduleTriggerPage> createState() => _ScheduleTriggerPageState();
}

class _ScheduleTriggerPageState extends State<ScheduleTriggerPage> {
  String selectedPeriod = "Điểm thời gian chỉ định"; // Mặc định chọn cái đầu
  TimeOfDay selectedTime = const TimeOfDay(hour: 11, minute: 10);
  String repeatMode = "Chỉ một lần";

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Hẹn giờ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Xử lý xác nhận
              final scheduleData = <String, dynamic>{
                'type': selectedPeriod,
                'time': selectedTime,
                'repeat': repeatMode,
              };
              // Trả dữ liệu về và chuyển sang trang tạo scene
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CreateScenePage(scheduleData: scheduleData),
                ),
              );
            },
            child: const Text(
              "Xác nhận",
              style: TextStyle(
                color: Colors.red,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. Điểm thời gian chỉ định (có tick đỏ)
            _buildPeriodOption(
              title: "Điểm thời gian chỉ định",
              isSelected: selectedPeriod == "Điểm thời gian chỉ định",
              onTap: () =>
                  setState(() => selectedPeriod = "Điểm thời gian chỉ định"),
            ),

            const SizedBox(height: 20),

            // 2. Mặt trời mọc / Hoàng hôn
            _buildPeriodOption(
              title: "Mặt trời mọc",
              isSelected: selectedPeriod == "Mặt trời mọc",
              onTap: () => setState(() => selectedPeriod = "Mặt trời mọc"),
            ),

            const SizedBox(height: 12),

            _buildPeriodOption(
              title: "Hoàng hôn",
              isSelected: selectedPeriod == "Hoàng hôn",
              onTap: () => setState(() => selectedPeriod = "Hoàng hôn"),
            ),

            const SizedBox(height: 30),

            // 3. Thời gian
            _buildTimePicker(),

            const SizedBox(height: 20),

            // 4. Lặp lại
            _buildRepeatPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 1.5,
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.red, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () => _selectTime(context),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Thời gian",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text(
                  selectedTime.format(context),
                  style: const TextStyle(fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatPicker() {
    return GestureDetector(
      onTap: () {
        // TODO: Mở dialog chọn lặp lại (hằng ngày, thứ 2-6, cuối tuần, v.v.)
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Chọn chế độ lặp",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Danh sách các lựa chọn
                _buildRepeatOption("Chỉ một lần"),
                _buildRepeatOption("Hằng ngày"),
                _buildRepeatOption("Thứ 2 đến Thứ 6"),
                _buildRepeatOption("Cuối tuần"),
                _buildRepeatOption("Tùy chỉnh..."),
              ],
            ),
          ),
        );
      },
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lặp lại",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text(
                  repeatMode,
                  style: const TextStyle(fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ tạo từng dòng trong bottom sheet
  Widget _buildRepeatOption(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 17)),
      trailing: repeatMode == title
          ? const Icon(Icons.check, color: Colors.red)
          : null,
      onTap: () {
        setState(() {
          repeatMode = title; // ← CẬP NHẬT BIẾN KHI CHỌN
        });
        Navigator.pop(context); // Đóng bottom sheet
      },
    );
  }
}
