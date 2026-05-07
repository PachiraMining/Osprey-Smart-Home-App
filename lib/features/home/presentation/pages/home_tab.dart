import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import '../../domain/entities/home_device_entity.dart';
import 'home_selector_sheet.dart';
import 'manage_home_page.dart';
import 'package:smart_curtain_app/features/device/domain/entities/device_entity.dart';
import 'package:smart_curtain_app/features/device/presentation/pages/curtain_control_page.dart';

/// HomeTab backed by HomeManagementBloc with room filtering and home switching.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeManagementBloc>();
    if (bloc.state.status == HomeStatus.initial) {
      bloc.add(const LoadHomesEvent());
    }
  }

  void _openHomeSelector() {
    final bloc = context.read<HomeManagementBloc>();
    final state = bloc.state;
    HomeSelectorDropdown.show(
      context: context,
      homes: state.homes,
      selectedHomeId: state.selectedHomeId,
      onSelect: (homeId) {
        bloc.add(SelectHomeEvent(homeId));
      },
      onManageHome: () {
        final homeId = state.selectedHomeId;
        final homeName = state.selectedHome?.name ?? '';
        if (homeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ManageHomePage(homeId: homeId, homeName: homeName),
            ),
          );
        }
      },
    );
  }

  void _navigateToDevice(HomeDeviceEntity homeDevice) {
    final device = DeviceEntity(
      id: homeDevice.deviceId,
      name: homeDevice.displayName,
      type: homeDevice.type ?? '',
      status: (homeDevice.isOnline ?? false) ? 'online' : 'offline',
      deviceProfileId: homeDevice.deviceProfileId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CurtainControlPage(device: device)),
    );
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId != null) {
      bloc.add(LoadHomeDevicesEvent(homeId));
      bloc.add(LoadRoomsEvent(homeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeManagementBloc, HomeManagementState>(
      builder: (context, state) {
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 18
                ? 'Good afternoon'
                : 'Good evening';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Greeting + home selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: state.homes.isNotEmpty ? _openHomeSelector : null,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.selectedHome?.name ?? 'My Home',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.unfold_more_rounded,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Room filter chips
            if (state.rooms.isNotEmpty)
              SizedBox(
                height: 38,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _RoomChip(
                        label: 'All',
                        isSelected: state.selectedRoomId == null,
                        onTap: () => context
                            .read<HomeManagementBloc>()
                            .add(const SelectRoomEvent(null)),
                      ),
                      ...state.rooms.map((room) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _RoomChip(
                              label: room.name,
                              isSelected: state.selectedRoomId == room.id,
                              onTap: () => context
                                  .read<HomeManagementBloc>()
                                  .add(SelectRoomEvent(room.id)),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Device list
            Expanded(child: _buildDeviceContent(state)),
          ],
        );
      },
    );
  }

  Widget _buildDeviceContent(HomeManagementState state) {
    if (state.status == HomeStatus.loading ||
        state.status == HomeStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 56, color: AppColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context
                    .read<HomeManagementBloc>()
                    .add(const LoadHomesEvent()),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final devices = state.filteredDevices;
    if (devices.isEmpty) {
      return _OspreyEmptyState(
        icon: Icons.cottage_outlined,
        title: 'No devices yet',
        message:
            'Tap the + button to add your first Osprey device to this home.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: devices.length + 1,
          itemBuilder: (context, index) {
            if (index == devices.length) {
              return const SizedBox(height: 120);
            }
            final device = devices[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DeviceCard(
                device: device,
                onTap: () => _navigateToDevice(device),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Branded empty state used across tabs — generous spacing, soft serif vibe.
class _OspreyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _OspreyEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(icon, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: AppTypography.headlineSmall
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped room filter chip with selected/unselected states.
class _RoomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoomChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Device card — outlined surface with status pill, distinct from typical
/// shadowed Material cards.
class _DeviceCard extends StatelessWidget {
  final HomeDeviceEntity device;
  final VoidCallback onTap;

  const _DeviceCard({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              // Device icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.curtains_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),

              // Name + status row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline
                                ? AppColors.statusOnline
                                : AppColors.statusOffline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: AppTypography.caption.copyWith(
                            color: isOnline
                                ? AppColors.statusOnline
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Power indicator
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? AppColors.primarySubtle
                      : AppColors.surfaceMuted,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  size: 22,
                  color: isOnline
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
