// lib/screens/create_scene_trigger_page.dart
import 'package:flutter/material.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/schedule_trigger_page.dart';

class CreateSceneTriggerPage extends StatelessWidget {
  const CreateSceneTriggerPage({super.key});

  final List<Map<String, dynamic>> triggers = const [
    {
      "icon": Icons.touch_app_outlined,
      "color": Colors.green,
      "title": "Chạm để chạy",
      "example": "Example: turn off all lights in the bedroom with one tap.",
    },
    {
      "icon": Icons.sensors_outlined,
      "color": Colors.orange,
      "title": "Khi trạng thái thiết bị thay đổi",
      "example": "Example: when an unusual activity is detected.",
    },
    {
      "icon": Icons.access_time,
      "color": Colors.blue,
      "title": "Lịch trình",
      "example": "Example: 7:00 a.m. every morning.",
      "page": const ScheduleTriggerPage(),
    },
    {
      "icon": Icons.wb_sunny_outlined,
      "color": Colors.amber,
      "title": "Khi thời tiết thay đổi",
      "example": "Example: when local temperature is greater than 28°C.",
    },
    {
      "icon": Icons.location_on_outlined,
      "color": Colors.red,
      "title": "Khi vị trí thay đổi",
      "example": "Example: after you leave home.",
    },
    {
      "icon": Icons.cloud_queue,
      "color": Colors.lightBlue,
      "title": "Disaster Warning",
      "example": "Example: 24-hour disaster warning for heavy rain and snow.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Thêm kịch bản thông minh",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Gợi ý màu xanh nhạt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Select how to trigger your scene.",
              style: TextStyle(color: Colors.green, fontSize: 15),
            ),
          ),

          const SizedBox(height: 12),

          // Danh sách trigger
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ), // ĐÃ SỬA DÒNG NÀY
              itemCount: triggers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = triggers[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (item["page"] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => item["page"] as Widget,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon tròn có nền màu
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (item["color"] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item["icon"] as IconData,
                            color: item["color"] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item["example"],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
