import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_bloc.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_event.dart';
import 'package:smart_curtain_app/features/device/presentation/bloc/device_state.dart';

import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';

class AddDeviceToHomePage extends StatefulWidget {
  final String homeId;

  const AddDeviceToHomePage({super.key, required this.homeId});

  @override
  State<AddDeviceToHomePage> createState() => _AddDeviceToHomePageState();
}

class _AddDeviceToHomePageState extends State<AddDeviceToHomePage> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // Refresh device list on open
    context.read<DeviceBloc>().add(LoadDevicesEvent());
  }

  void _toggleDevice(String deviceId) {
    setState(() {
      if (_selectedIds.contains(deviceId)) {
        _selectedIds.remove(deviceId);
      } else {
        _selectedIds.add(deviceId);
      }
    });
  }

  void _addSelected() {
    if (_selectedIds.isEmpty) return;
    final bloc = context.read<HomeManagementBloc>();
    for (final deviceId in _selectedIds) {
      bloc.add(AddDeviceToHomeEvent(homeId: widget.homeId, deviceId: deviceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeManagementBloc, HomeManagementState>(
      listenWhen: (prev, curr) => curr.mutationStatus != prev.mutationStatus,
      listener: (context, state) {
        if (state.mutationStatus == MutationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device added to home'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.mutationStatus == MutationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Add Device to Home'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (context, deviceState) {
            if (deviceState is DeviceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (deviceState is DeviceError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      deviceState.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DeviceBloc>().add(LoadDevicesEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (deviceState is DeviceLoaded) {
              final devices = deviceState.devices;

              if (devices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.devices_other_outlined,
                          size: 64, color: Colors.black26),
                      SizedBox(height: 12),
                      Text(
                        'No devices available',
                        style:
                            TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: devices.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final selected = _selectedIds.contains(device.id);
                        return _DeviceTile(
                          device: device,
                          selected: selected,
                          onToggle: () => _toggleDevice(device.id),
                        );
                      },
                    ),
                  ),
                  _AddButton(
                    selectedCount: _selectedIds.length,
                    onPressed: _addSelected,
                  ),
                ],
              );
            }

            // DeviceInitial or unknown state — trigger load
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final DeviceEntity device;
  final bool selected;
  final VoidCallback onToggle;

  const _DeviceTile({
    required this.device,
    required this.selected,
    required this.onToggle,
  });

  static const _blue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline;
    return ListTile(
      onTap: onToggle,
      leading: CircleAvatar(
        backgroundColor: isOnline
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFF5F5F5),
        child: Icon(
          Icons.devices_other_outlined,
          color: isOnline ? _blue : Colors.black38,
        ),
      ),
      title: Text(device.name),
      subtitle: Text(
        isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: isOnline ? Colors.green : Colors.black38,
          fontSize: 12,
        ),
      ),
      trailing: Checkbox(
        value: selected,
        onChanged: (_) => onToggle(),
        activeColor: _blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPressed;

  const _AddButton({
    required this.selectedCount,
    required this.onPressed,
  });

  static const _blue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: ElevatedButton(
        onPressed: selectedCount > 0 ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          disabledBackgroundColor: Colors.black12,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          selectedCount > 0
              ? 'Add ($selectedCount devices)'
              : 'Add',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
