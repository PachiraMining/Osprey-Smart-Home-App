import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_state.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/device_action_page.dart';

class SelectSingleDevicePage extends StatelessWidget {
  const SelectSingleDevicePage({super.key});

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
          "Chon thiet bi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "Tat ca thiet bi",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Smart Curtain",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<DeviceBloc, DeviceState>(
              builder: (context, state) {
                if (state is DeviceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DeviceError) {
                  return Center(child: Text('Loi: ${state.message}'));
                }
                if (state is DeviceLoaded) {
                  final devices = state.devices;
                  if (devices.isEmpty) {
                    return const Center(child: Text('Khong co thiet bi nao'));
                  }
                  return _buildDeviceList(context, devices);
                }
                return const Center(child: Text('Dang tai...'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, List<DeviceEntity> devices) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final bool isOffline = device.isOffline;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              // Convert DeviceEntity to Map for DeviceActionPage
              final deviceMap = {
                'id': device.id,
                'name': device.name,
                'type': device.type,
                'status': isOffline ? 'Ngoai tuyen' : 'Online',
              };
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceActionPage(device: deviceMap),
                ),
              );
              if (result != null) {
                Navigator.pop(context, result);
              }
            },
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
                        device.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isOffline)
                        Text(
                          "Ngoai tuyen",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
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
    );
  }
}
