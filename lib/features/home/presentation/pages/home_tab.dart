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
import '../../../ai/domain/entities/voice_intent.dart';
import '../../../ai/presentation/bloc/ai_suggestion_bloc.dart';
import '../../../ai/presentation/bloc/voice_command_bloc.dart';
import '../../../ai/presentation/bloc/weather_ai_bloc.dart';
import '../../../ai/presentation/widgets/ai_suggestion_card.dart';
import '../../../ai/presentation/widgets/voice_command_button.dart';
import '../../../ai/presentation/widgets/weather_ai_banner.dart';
import '../../../device/domain/usecases/send_device_command.dart';
import 'package:get_it/get_it.dart';

/// HomeTab backed by HomeManagementBloc with room filtering and home switching.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  /// Message hiển thị khi mutation kế tiếp thành công (gỡ/xóa/đổi tên).
  /// Set ngay trước khi dispatch event, BlocListener consume khi success.
  String? _pendingSuccessMessage;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeManagementBloc>();
    if (bloc.state.status == HomeStatus.initial) {
      bloc.add(const LoadHomesEvent());
    }
    // Kick off AI features so cards/banners can populate as soon as data arrives.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AiSuggestionBloc>().add(const LoadSuggestions());
      context.read<WeatherAiBloc>().add(const RefreshWeather());
    });
  }

  void _onVoiceIntent(VoiceCommandReady state) {
    final intent = state.intent;
    final devices = context.read<HomeManagementBloc>().state.filteredDevices;
    if (devices.isEmpty) return;

    // Fuzzy match: prefer device whose display name contains the hint.
    final target = intent.deviceHint.isNotEmpty
        ? devices.firstWhere(
            (d) => d.displayName.toLowerCase().contains(intent.deviceHint.toLowerCase()),
            orElse: () => devices.first,
          )
        : devices.first;

    final sendCommand = GetIt.instance<SendDeviceCommand>();
    final command = switch (intent.action) {
      VoiceAction.open => 'open',
      VoiceAction.close => 'close',
      VoiceAction.stop => 'stop',
      VoiceAction.setPosition => '${intent.position ?? 50}',
      VoiceAction.unknown => null,
    };
    if (command == null) return;
    sendCommand(target.deviceId, command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice: ${intent.transcript}  →  ${target.displayName}'),
      ),
    );
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

  /// Long-press card thiết bị → menu hành động (pattern Tuya).
  void _showDeviceActions(HomeDeviceEntity device) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Đổi tên thiết bị'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showRenameDeviceDialog(device);
              },
            ),
            const Divider(height: 1),
            // Nút 1 — Ngắt kết nối (DELETE, không wipe ngay, ~1-2 phút)
            ListTile(
              leading: const Icon(Icons.link_off, color: AppColors.warning),
              title: const Text('Ngắt kết nối'),
              subtitle: const Text(
                'Gỡ khỏi nhà, thiết bị tự về chế độ ghép nối sau 1-2 phút',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDisconnect(device);
              },
            ),
            // Nút 2 — Hủy liên kết và xóa dữ liệu (POST factory-reset, RPC wipe)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text(
                'Hủy liên kết và xóa dữ liệu',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: const Text(
                'Xóa toàn bộ dữ liệu, không thể khôi phục',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmFactoryReset(device);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Nút 1 — Ngắt kết nối: confirm rồi DELETE.
  Future<void> _confirmDisconnect(HomeDeviceEntity device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ngắt kết nối thiết bị?'),
        content: Text(
          '"${device.displayName}" sẽ được gỡ khỏi nhà của bạn và tự động '
          'chuyển về chế độ ghép nối trong khoảng 1-2 phút.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ngắt kết nối'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage =
        'Đã ngắt thiết bị khỏi nhà. Thiết bị sẽ về chế độ ghép nối '
        'trong 1-2 phút.';
    bloc.add(RemoveDeviceFromHomeEvent(
      homeId: homeId,
      deviceId: device.deviceId,
    ));
  }

  /// Nút 2 — Hủy liên kết và xóa dữ liệu: confirm (cảnh báo mạnh) rồi POST.
  Future<void> _confirmFactoryReset(HomeDeviceEntity device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa dữ liệu thiết bị?'),
        content: Text(
          'Toàn bộ dữ liệu của "${device.displayName}" sẽ bị xóa và '
          'KHÔNG THỂ khôi phục. Bạn chắc chắn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage =
        'Đã xóa thiết bị. Thiết bị đang trở về chế độ ghép nối.';
    bloc.add(FactoryResetDeviceEvent(
      homeId: homeId,
      deviceId: device.deviceId,
    ));
  }

  Future<void> _showRenameDeviceDialog(HomeDeviceEntity device) async {
    final controller = TextEditingController(text: device.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Đổi tên thiết bị'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'Tên thiết bị',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage = 'Đã đổi tên thiết bị.';
    // PUT backend là full-replace — truyền kèm roomId + sortOrder hiện tại
    // để không bị reset (văng device khỏi room).
    bloc.add(UpdateHomeDeviceEvent(
      homeId: homeId,
      deviceId: device.deviceId,
      deviceName: newName,
      roomId: device.roomId,
      sortOrder: device.sortOrder,
    ));
  }

  /// Hiển thị kết quả mutation do home_tab khởi tạo (gỡ/xóa/đổi tên).
  /// Gate theo [_pendingSuccessMessage] để không bắt nhầm mutation của
  /// trang khác (add device, create home...).
  void _onMutationResult(BuildContext context, HomeManagementState state) {
    final pending = _pendingSuccessMessage;
    if (pending == null) return;
    if (state.mutationStatus == MutationStatus.success) {
      _pendingSuccessMessage = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(pending),
        backgroundColor: AppColors.success,
      ));
    } else if (state.mutationStatus == MutationStatus.error) {
      _pendingSuccessMessage = null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.errorMessage ?? 'Có lỗi xảy ra, vui lòng thử lại'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeManagementBloc, HomeManagementState>(
      listenWhen: (prev, curr) =>
          prev.mutationStatus != curr.mutationStatus,
      listener: _onMutationResult,
      child: BlocBuilder<HomeManagementBloc, HomeManagementState>(
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

            // AI: weather banner (visible only when WeatherLoaded state)
            const WeatherAiBanner(),

            // AI: pattern suggestion card (visible only when suggestions loaded)
            const AiSuggestionCard(),

            const SizedBox(height: 12),

            // Device list
            Expanded(
              child: Stack(
                children: [
                  _buildDeviceContent(state),
                  Positioned(
                    right: 20,
                    // Bottom nav is a floating pill: SafeArea + 12 pad + 68 height
                    // ≈ 114px on iPhone with home indicator. Add 40 breathing room.
                    bottom: MediaQuery.of(context).viewPadding.bottom + 130,
                    child: VoiceCommandButton(onIntentReady: _onVoiceIntent),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      ),
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
      return _BrandEmptyState(
        icon: Icons.cottage_outlined,
        title: 'No devices yet',
        message:
            'Tap the + button to add your first curtain to this home.',
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
                onLongPress: () => _showDeviceActions(device),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Branded empty state used across tabs — generous spacing, soft serif vibe.
class _BrandEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _BrandEmptyState({
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
  final VoidCallback? onLongPress;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        onLongPress: onLongPress,
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
