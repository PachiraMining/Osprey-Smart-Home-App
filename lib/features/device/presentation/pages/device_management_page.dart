// lib/features/device/presentation/pages/device_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_event.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_state.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';
import 'device_control_page.dart';

class DeviceManagementPage extends StatefulWidget {
  const DeviceManagementPage({Key? key}) : super(key: key);

  @override
  State<DeviceManagementPage> createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends State<DeviceManagementPage> {
  String _filterType = 'All'; // All, WiFi, Bluetooth, Zigbee

  @override
  void initState() {
    super.initState();
    // Load devices khi vào trang
    context.read<DeviceBloc>().add(LoadDevicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Device Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),

          // Device list
          Expanded(
            child: BlocBuilder<DeviceBloc, DeviceState>(
              builder: (context, state) {
                if (state is DeviceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DeviceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DeviceBloc>().add(LoadDevicesEvent());
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else if (state is DeviceLoaded) {
                  final filteredDevices = _filterDevices(state.devices);

                  if (filteredDevices.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<DeviceBloc>().add(RefreshDevicesEvent());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, index) {
                        return _buildDeviceCard(filteredDevices[index]);
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Filter Devices',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, size: 20),
          const Spacer(),
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceLoaded) {
                return Text(
                  '(${_filterDevices(state.devices).length})',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  List<DeviceEntity> _filterDevices(List<DeviceEntity> devices) {
    if (_filterType == 'All') return devices;

    return devices.where((device) {
      final type = device.connectionType?.toLowerCase() ?? '';
      switch (_filterType) {
        case 'WiFi':
          return type == 'wifi';
        case 'Bluetooth':
          return type == 'bluetooth';
        case 'Zigbee':
          return type == 'zigbee';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildDeviceCard(DeviceEntity device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: _buildDeviceIcon(device),
        title: Text(
          device.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              device.connectionType?.toUpperCase() ?? 'Unknown',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: device.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  device.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: device.isOnline ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'control') {
              // THÊM: Navigate to control page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceControlPage(device: device),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteConfirmation(device);
            } else if (value == 'rename') {
              _showRenameDialog(device);
            } else if (value == 'details') {
              _showDeviceDetails(device);
            }
          },
          itemBuilder: (context) => [
            // THÊM: Menu item điều khiển
            const PopupMenuItem(
              value: 'control',
              child: Row(
                children: [
                  Icon(Icons.settings_remote_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Điều khiển'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Chi tiết'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Đổi tên'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        // UPDATE: Click vào device card → Navigate to control page
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeviceControlPage(device: device),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceIcon(DeviceEntity device) {
    IconData icon;
    Color color;

    if (device.isOffline) {
      color = Colors.grey;
    } else {
      color = Colors.blue;
    }

    switch (device.connectionType?.toLowerCase()) {
      case 'wifi':
        icon = Icons.wifi;
        break;
      case 'bluetooth':
        icon = Icons.bluetooth;
        break;
      case 'zigbee':
        icon = Icons.hub_outlined;
        break;
      default:
        icon = Icons.devices_other;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có thiết bị nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm thiết bị mới để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DeviceEntity device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thiết bị?'),
        content: Text('Bạn có chắc muốn xóa "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<DeviceBloc>().add(DeleteDeviceEvent(device.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa ${device.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(DeviceEntity device) {
    final controller = TextEditingController(text: device.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên thiết bị'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement rename
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đổi tên thiết bị'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(DeviceEntity device) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type', device.type),
            _buildDetailRow('Connection', device.connectionType ?? '-'),
            _buildDetailRow('Status', device.isOnline ? 'Online' : 'Offline'),
            if (device.id != null) _buildDetailRow('Device ID', device.id!),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.pop(context);
                // Navigate to device control
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeviceControlPage(device: device),
                  ),
                );
              },
              child: const Text('Điều khiển thiết bị'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
