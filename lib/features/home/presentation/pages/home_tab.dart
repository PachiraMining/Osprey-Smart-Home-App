import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_pull_refresh.dart';
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
import '../../../ai/presentation/widgets/weather_card.dart';
import '../../../scene/presentation/widgets/tap_to_run_pills.dart';
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
    // The weather cell now lives in the same pull — refresh it too.
    context.read<WeatherAiBloc>().add(const RefreshWeather());
    // Hold the glowing bulb long enough to be seen (events above are
    // fire-and-forget; the list updates via bloc state when they land).
    await Future.delayed(const Duration(milliseconds: 1000));
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
              title: const Text('Rename device'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showRenameDeviceDialog(device);
              },
            ),
            const Divider(height: 1),
            // Nút 1 — Ngắt kết nối (DELETE, không wipe ngay, ~1-2 phút)
            ListTile(
              leading: const Icon(Icons.link_off, color: AppColors.warning),
              title: const Text('Disconnect'),
              subtitle: const Text(
                'Removes from home; device returns to pairing mode in 1-2 minutes',
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
                'Unlink and erase data',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: const Text(
                'Erases all data, cannot be undone',
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
        title: const Text('Disconnect device?'),
        content: Text(
          '"${device.displayName}" will be removed from your home and '
          'automatically return to pairing mode in about 1-2 minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage =
        'Device disconnected from home. It will return to pairing mode '
        'in 1-2 minutes.';
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
        title: const Text('Erase device data?'),
        content: Text(
          'All data for "${device.displayName}" will be erased and '
          'CANNOT be recovered. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage =
        'Device deleted. It is returning to pairing mode.';
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
        title: const Text('Rename device'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'Device name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || !mounted) return;

    final bloc = context.read<HomeManagementBloc>();
    final homeId = bloc.state.selectedHomeId;
    if (homeId == null) return;
    _pendingSuccessMessage = 'Device renamed.';
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
        content: Text(state.errorMessage ?? 'Something went wrong, please try again'),
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
        // ONE scroll surface: pull-to-refresh bulb + weather cell + room chips
        // + device list all live in the same CustomScrollView, so everything
        // slides together (Tuya-style) and the bulb appears above the weather
        // cell when pulling down.
        return AppPullRefresh(
          onRefresh: _onRefresh,
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 9),

                  // Tuya-style outdoor weather cell
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: WeatherCard(),
                  ),

                  const SizedBox(height: 12),

                  // Tap-to-Run quick-run pills (Tuya-style, scene colors)
                  const TapToRunPills(),

                  const SizedBox(height: 14),

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
                                    isSelected:
                                        state.selectedRoomId == room.id,
                                    onTap: () => context
                                        .read<HomeManagementBloc>()
                                        .add(SelectRoomEvent(room.id)),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),

                  // AI: weather banner — ẩn theo yêu cầu (2026-07).
                  // const WeatherAiBanner(),

                  // AI: pattern suggestion card
                  const AiSuggestionCard(),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Device list / status states (as slivers in the same scroll)
            _buildDeviceSliver(state),
          ],
          ),
        );
      },
      ),
    );
  }

  Widget _buildDeviceSliver(HomeManagementState state) {
    if (state.status == HomeStatus.loading ||
        state.status == HomeStatus.initial) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == HomeStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
        ),
      );
    }

    final devices = state.filteredDevices;
    if (devices.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _BrandEmptyState(
          icon: Icons.cottage_outlined,
          title: 'No devices yet',
          message:
              'Tap the + button to add your first curtain to this home.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
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
    // Text-only tab, styled like the Automation / Tap-to-Run header: no
    // background, no border — the selected room is simply bold black.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: isSelected ? 16 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: isSelected ? Colors.black87 : Colors.grey,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Device card — outlined surface with status pill, distinct from typical
/// shadowed Material cards.
class _DeviceCard extends StatefulWidget {
  final HomeDeviceEntity device;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  /// Whether the in-cell "Common Functions" quick controls are expanded.
  bool _expanded = false;

  HomeDeviceEntity get device => widget.device;

  void _send(String command) {
    GetIt.instance<SendDeviceCommand>()(device.deviceId, command);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Row(
            children: [
              // Device icon — curtain track product artwork (white tile like Tuya)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/icons/curtain_track.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.curtains_outlined,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
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
                    // Curtain-track quick controls toggle (Tuya-style
                    // "Common Functions") — online devices only.
                    if (isOnline)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Common Functions',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accentDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0,
                                duration:
                                    const Duration(milliseconds: 180),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 17,
                                  color: AppColors.accentDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Trailing: power indicator when online, BT-disconnected when not
              if (isOnline)
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySubtle,
                  ),
                  child: const Icon(
                    Icons.power_settings_new_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                )
              else
                SizedBox(
                  width: 42,
                  height: 42,
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: SvgPicture.asset(
                      'assets/icons/bluetooth_disconnect.svg',
                      colorFilter: const ColorFilter.mode(
                        AppColors.textMuted,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),

              // Expanded quick actions — open/pause/close without leaving Home.
              if (isOnline && _expanded)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAction(
                        label: 'Open',
                        icon: Image.asset(
                          'assets/icons/curtain_open.png',
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.keyboard_double_arrow_left,
                              size: 22,
                              color: AppColors.primary),
                        ),
                        onTap: () => _send('open'),
                      ),
                      _QuickAction(
                        label: 'Pause',
                        icon: const Icon(Icons.pause_rounded,
                            size: 24, color: AppColors.primary),
                        onTap: () => _send('stop'),
                      ),
                      _QuickAction(
                        label: 'Close',
                        icon: Image.asset(
                          'assets/icons/curtain_close.png',
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.keyboard_double_arrow_right,
                              size: 22,
                              color: AppColors.primary),
                        ),
                        onTap: () => _send('close'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular quick-action button + label used inside the device cell.
class _QuickAction extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySubtle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
