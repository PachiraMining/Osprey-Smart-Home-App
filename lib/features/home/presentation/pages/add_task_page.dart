// lib/screens/add_task_page.dart
import 'package:flutter/material.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/select_single_device_page.dart';

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  final List<Map<String, dynamic>> tasks = const [
    {
      "icon": Icons.lightbulb_outline,
      "color": Colors.amber,
      "title": "Device",
      "example": "Example: open the curtains",
    },
    {
      "icon": Icons.auto_awesome,
      "color": Colors.blue,
      "title": "Chọn Kịch bản thông minh",
      "example": "Example: disable a specific automation scene",
    },
    {
      "icon": Icons.timer_outlined,
      "color": Colors.orange,
      "title": "Thời gian trôi đi",
      "example": "Example: run the scene in 15 minutes",
    },
    {
      "icon": Icons.notifications_active_outlined,
      "color": Colors.green,
      "title": "Gửi thông báo nhắc nhở",
      "example":
          "Example: make a phone call to alert me if a water leak is detected",
    },
    {
      "icon": Icons.camera_alt_outlined,
      "color": Colors.teal,
      "title": "Room Snapshot (Beta)",
      "example": "Example: capture the room's current state as one action.",
    },
  ];

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
            "Hủy bỏ",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          "Thêm tác vụ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = tasks[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (item["title"] == "Device") {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (bottomSheetContext) => Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Thanh kéo
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Device",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Select multiple devices
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildBottomSheetButton(
                            title: "Select multiple devices",
                            onTap: () => Navigator.pop(bottomSheetContext),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Select a single device – ĐÃ SỬA HOÀN HẢO TẠI ĐÂY
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildBottomSheetButton(
                            title: "Select a single device",
                            onTap: () async {
                              // 1. Đóng bottom sheet trước (dùng bottomSheetContext để tránh lỗi context)
                              Navigator.pop(bottomSheetContext);

                              // 2. Mở trang chọn thiết bị và chờ kết quả
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SelectSingleDevicePage(),
                                ),
                              );

                              // 3. Nếu có kết quả → TRẢ VỀ NGAY CHO CreateScenePage
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                // Dùng context của AddTaskPage (context gốc) để pop đúng
                                Navigator.of(context).pop(result);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã chọn: ${item['title']}")),
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
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSheetButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
