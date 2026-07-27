import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_popup.dart';
import '../../../../core/widgets/app_pull_refresh.dart';
import '../../../../core/cache/hidden_device_store.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import '../../domain/entities/home_device_entity.dart';
import 'home_selector_sheet.dart';
import 'manage_home_page.dart';
import 'all_devices_manage_page.dart';
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
import 'package:dartz/dartz.dart' show Either;
import '../../../device/domain/usecases/send_device_command.dart';
import '../../../device/domain/usecases/get_device_status.dart';
import '../../../device/domain/usecases/send_dp_command.dart';
import '../../../../core/error/failure.dart';
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

  /// Expander "Show invisible devices" mở hay đóng.
  bool _showHidden = false;

  @override
  void initState() {
    super.initState();
    HiddenDeviceStore.instance.ensureLoaded();
    final bloc = context.read<HomeManagementBloc>();
    // Revalidate on mount even when hydrated cache restored a `loaded` state —
    // the bloc's own re-entrancy guard blocks a concurrent load. This is the
    // "revalidate" half of stale-while-revalidate.
    if (bloc.state.status != HomeStatus.loading) {
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
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Disconnect device?',
      message:
          '"${device.displayName}" will be removed from your home and '
          'automatically return to pairing mode in about 1-2 minutes.',
      confirmText: 'Disconnect',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

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
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Erase device data?',
      message:
          'All data for "${device.displayName}" will be erased and '
          'CANNOT be recovered. Are you sure?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

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
    final newName = await AppDialog.prompt(
      context,
      title: 'Rename device',
      initialValue: device.displayName,
      hintText: 'Device name',
      confirmText: 'Save',
    );
    if (newName == null || !mounted) return;

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
      AppPopup.success(context, title: 'Done', message: pending);
    } else if (state.mutationStatus == MutationStatus.error) {
      _pendingSuccessMessage = null;
      AppPopup.error(
        context,
        title: 'Failed',
        message: _isNetworkError(state.errorMessage)
            ? 'No connection. Check your internet and try again.'
            : (state.errorMessage ?? 'Something went wrong, please try again'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HiddenDeviceStore.instance,
      builder: (context, _) => BlocListener<HomeManagementBloc, HomeManagementState>(
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
    ),
    );
  }

  /// True when [raw] looks like a "can't reach the server" network error
  /// (host lookup / socket / timeout / connection) rather than a real backend
  /// rejection — so we can show a clean, non-technical message instead of the
  /// raw Dio/Socket string (which also leaks the internal host name).
  bool _isNetworkError(String? raw) {
    if (raw == null) return false;
    final s = raw.toLowerCase();
    return s.contains('failed host lookup') ||
        s.contains('socketexception') ||
        s.contains('connection error') ||
        s.contains('connection errored') ||
        s.contains('connection refused') ||
        s.contains('connection closed') ||
        s.contains('network is unreachable') ||
        s.contains('timed out') ||
        s.contains('timeout');
  }

  String _friendlyErrorTitle(String? raw) =>
      _isNetworkError(raw) ? 'No connection' : 'Something went wrong';

  String _friendlyErrorBody(String? raw) => _isNetworkError(raw)
      ? 'Check your internet connection and try again.'
      : 'We couldn\'t load your home. Please try again.';

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
                _friendlyErrorTitle(state.errorMessage),
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _friendlyErrorBody(state.errorMessage),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
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

    final all = state.filteredDevices;
    if (all.isEmpty) {
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

    // Hidden devices are pulled out of the main list and tucked under a
    // "Show invisible devices" expander at the bottom (local hide preference).
    final hiddenIds = HiddenDeviceStore.instance.hiddenFor(state.selectedHomeId);
    final visible =
        all.where((d) => !hiddenIds.contains(d.deviceId)).toList();
    final hidden = all.where((d) => hiddenIds.contains(d.deviceId)).toList();

    final items = <Widget>[
      for (final d in visible) _deviceTile(d),
      if (hidden.isNotEmpty) _invisibleExpander(hidden.length),
      if (hidden.isNotEmpty && _showHidden)
        for (final d in hidden) _deviceTile(d),
      const SizedBox(height: 120),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(delegate: SliverChildListDelegate(items)),
    );
  }

  Widget _deviceTile(HomeDeviceEntity device) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _DeviceCard(
        device: device,
        // Offline devices can't be controlled — block the tap into the
        // control page and tell the user why instead.
        onTap: () {
          if (device.isOnline ?? false) {
            _navigateToDevice(device);
          } else {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(const SnackBar(
                content: Text('Device is offline'),
                duration: Duration(seconds: 2),
              ));
          }
        },
        onLongPress: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllDevicesManagePage()),
        ),
      ),
    );
  }

  /// Bottom expander toggling the hidden-device section.
  Widget _invisibleExpander(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showHidden = !_showHidden),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showHidden
                  ? 'Hide invisible devices'
                  : 'Show invisible devices ($count)',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _showHidden ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down,
                  size: 20, color: AppColors.textSecondary),
            ),
          ],
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
  /// Whether the in-cell "Common Functions" controls are expanded.
  bool _expanded = false;

  /// Live device status (DP code → value) read from GET /devices/{id}/status.
  Map<String, dynamic>? _status;
  bool _busy = false;

  HomeDeviceEntity get device => widget.device;

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded && _status == null) _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final res = await GetIt.instance<GetDeviceStatus>()(device.deviceId);
    if (!mounted) return;
    res.fold((_) {}, (s) => setState(() => _status = s));
  }

  /// Apply a DP write then refresh status. Error → popup; success → re-read.
  Future<void> _apply(Future<Either<Failure, void>> Function() send) async {
    if (_busy) return;
    setState(() => _busy = true);
    final res = await send();
    if (!mounted) return;
    setState(() => _busy = false);
    res.fold(
      (_) => AppPopup.error(context,
          title: 'Failed',
          message: 'Could not send the command. Please try again.'),
      (_) => _fetchStatus(),
    );
  }

  // ─── Popup 1: Control (Open / Stop / Close) — dpId 1 ────────────────
  void _controlSheet() {
    final current = _status?['control'] as String?;
    _radioSheet(
      title: 'Control',
      options: const [('open', 'Open'), ('stop', 'Stop'), ('close', 'Close')],
      current: current,
      onSelect: (v) => _apply(
          () => GetIt.instance<SendDeviceCommand>()(device.deviceId, v)),
    );
  }

  // ─── Popup 3: Motor Direction (Forward / Back) — dpId 5 ─────────────
  void _motorSheet() {
    final current = _status?['control_back'] as String? ?? 'forward';
    _radioSheet(
      title: 'Motor Direction',
      options: const [('forward', 'Forward'), ('back', 'Back')],
      current: current,
      onSelect: (v) => _apply(
          () => GetIt.instance<SendDpCommand>()(device.deviceId, 5, v)),
    );
  }

  /// Floating bottom sheet: inset 10px from left/right/bottom, above the safe
  /// area, rounded on all corners.
  Future<T?> _floatingSheet<T>(WidgetBuilder builder) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: builder(ctx),
        ),
      ),
    );
  }

  void _radioSheet({
    required String title,
    required List<(String, String)> options,
    required String? current,
    required void Function(String value) onSelect,
  }) {
    // Selection stays; tapping ticks + runs the command but KEEPS the sheet
    // open. It only closes when the user taps outside (barrier).
    var selected = current;
    _floatingSheet<void>(
      (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 13),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              for (final (value, label) in options)
                ListTile(
                  dense: true,
                  title: Text(label,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textPrimary)),
                  trailing: value == selected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 22)
                      : Icon(Icons.circle_outlined,
                          color: Colors.grey.shade300, size: 22),
                  onTap: () {
                    if (value == selected) return;
                    setSheet(() => selected = value);
                    onSelect(value);
                  },
                ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  // ─── Popup 2: Curtain position setting (0–100%) — dpId 2 ────────────
  void _positionSheet() {
    final raw = _status?['percent_state'] ?? _status?['percent_control'];
    var pct = (raw is num ? raw.toInt() : 0).clamp(0, 100);
    _floatingSheet<void>(
      (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Curtain position setting',
                    style: TextStyle(
                        fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 34),
                      color: AppColors.textSecondary,
                      onPressed: pct <= 0
                          ? null
                          : () => setSheet(() => pct = (pct - 1).clamp(0, 100)),
                    ),
                    SizedBox(
                      width: 96,
                      child: Text('$pct%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 34),
                      color: AppColors.textSecondary,
                      onPressed: pct >= 100
                          ? null
                          : () => setSheet(() => pct = (pct + 1).clamp(0, 100)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _PositionBar(
                  value: pct,
                  onChanged: (v) => setSheet(() => pct = v),
                  // Apply on release but keep the sheet open — it closes only
                  // when the user taps outside.
                  onChangeEnd: (v) => _apply(
                      () => GetIt.instance<SendDeviceCommand>()(
                          device.deviceId, v.toString())),
                ),
              ],
            ),
          ),
        ),
    );
  }

  String get _controlLabel {
    switch (_status?['control'] as String?) {
      case 'open':
        return 'Open';
      case 'close':
        return 'Close';
      case 'stop':
        return 'Stop';
      default:
        return '--';
    }
  }

  String get _positionLabel {
    final raw = _status?['percent_state'] ?? _status?['percent_control'];
    return raw is num ? '${raw.toInt()}%' : '--';
  }

  String get _motorLabel {
    switch (_status?['control_back'] as String?) {
      case 'back':
        return 'Back';
      case 'forward':
      default:
        return 'Forward'; // default direction is Forward
    }
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
          // Trong suốt hơn để lộ nền ảnh, cao hơn chút, viền nhạt hơn.
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(140),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(90), width: 0.5),
          ),
          child: Column(
            children: [
              Row(
            children: [
              // Device icon — curtain-track artwork CHỈ khi device profile là
              // curtain track; loại khác dùng icon chung. Offline → làm mờ để
              // báo thiết bị không điều khiển được.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  // Tile trắng ĐỤC luôn (không xuyên thấu) — kể cả khi offline.
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // Offline → chỉ làm mờ ẢNH rèm bên trong, nền ô vẫn trắng đục.
                  child: Opacity(
                    opacity: isOnline ? 1.0 : 0.4,
                    child: device.isCurtainTrack
                        ? Padding(
                            padding: const EdgeInsets.all(3),
                            child: Image.asset(
                              'assets/icons/curtain_track.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.curtains_outlined,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.devices_other,
                            size: 26,
                            color: AppColors.textSecondary,
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
                        onTap: _toggleExpand,
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

              // Trailing:
              //  • Curtain track → no on/off (controlled via Common Functions);
              //    offline shows a yellow "Offline" label instead.
              //  • Other devices (socket…) → power button, green when on /
              //    grey when off.
              if (device.isCurtainTrack)
                (isOnline
                    ? const SizedBox.shrink()
                    : const Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF5A623),
                        ),
                      ))
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isOnline
                            ? const Color(0xFF2ECC71)
                            : AppColors.textMuted)
                        .withAlpha(28),
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 22,
                    color: isOnline
                        ? const Color(0xFF2ECC71)
                        : AppColors.textMuted,
                  ),
                ),
            ],
          ),

              // Common Functions — 3 columns reading live status, each opening
              // its popup: Control / Curtain position / Motor Direction.
              if (isOnline && _expanded)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CommonFn(
                        icon: const Icon(Icons.power_settings_new_rounded,
                            size: 26, color: Color(0xFF42A5F5)),
                        label: 'Control',
                        value: _controlLabel,
                        onTap: _controlSheet,
                      ),
                      _CommonFn(
                        icon: const Icon(Icons.percent_rounded,
                            size: 24, color: Color(0xFF2ECC71)),
                        label: 'Curtain position',
                        value: _positionLabel,
                        onTap: _positionSheet,
                      ),
                      _CommonFn(
                        icon: const Icon(Icons.grid_view_rounded,
                            size: 24, color: Color(0xFFE0824A)),
                        label: 'Motor Direction',
                        value: _motorLabel,
                        onTap: _motorSheet,
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
/// One Common-Functions column (Tuya style): icon, label, and the current
/// value read from device status; tapping opens its control popup.
class _CommonFn extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _CommonFn({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30, child: Center(child: icon)),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thick draggable position bar (Tuya style): a tall light-blue track with a
/// white grab handle you slide from 0–100%.
class _PositionBar extends StatelessWidget {
  final int value; // 0–100
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;

  const _PositionBar({
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  static const double _barHeight = 56;
  static const double _handleWidth = 28;

  int _pctFromDx(double dx, double width) {
    final usable = width - _handleWidth;
    if (usable <= 0) return 0;
    final x = (dx - _handleWidth / 2).clamp(0.0, usable);
    return (x / usable * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final handleX = (value / 100) * (width - _handleWidth);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => onChanged(_pctFromDx(d.localPosition.dx, width)),
          onHorizontalDragUpdate: (d) =>
              onChanged(_pctFromDx(d.localPosition.dx, width)),
          onHorizontalDragEnd: (_) => onChangeEnd(value),
          child: SizedBox(
            height: _barHeight,
            width: double.infinity,
            child: Stack(
              children: [
                // Unfilled track.
                Container(
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEBFA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                // Filled portion: 0 → selected %, up to the handle centre.
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: handleX + _handleWidth / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                Positioned(
                  left: handleX,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: _handleWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: const Color(0xFFCBD9E8), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
