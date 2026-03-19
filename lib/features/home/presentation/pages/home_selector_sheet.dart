import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

/// Bottom sheet for switching between homes.
class HomeSelectorSheet extends StatelessWidget {
  final List<HomeEntity> homes;
  final String? selectedHomeId;
  final void Function(String homeId) onSelect;
  final void Function(String homeId) onManage;
  final void Function(String name) onCreate;

  const HomeSelectorSheet({
    super.key,
    required this.homes,
    this.selectedHomeId,
    required this.onSelect,
    required this.onManage,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Chọn nhà',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Home list
          ...homes.map((home) {
            final isSelected = home.id == selectedHomeId;
            return ListTile(
              leading: Icon(
                Icons.home_outlined,
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              ),
              title: Text(
                home.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Icon(Icons.check, color: Color(0xFF2196F3), size: 22),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onManage(home.id),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.grey.shade500,
                      size: 22,
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelect(home.id);
                Navigator.pop(context);
              },
            );
          }),

          const Divider(height: 1),

          // Create new home button
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Color(0xFF2196F3)),
            title: const Text(
              'Tạo nhà mới',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2196F3),
              ),
            ),
            onTap: () => _showCreateDialog(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo nhà mới'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tên nhà',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                onCreate(name);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
