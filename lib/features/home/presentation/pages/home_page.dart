// home_page.dart
import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:smart_curtain_app/core/theme/app_colors.dart';
import 'package:smart_curtain_app/core/theme/app_radius.dart';
import 'package:smart_curtain_app/core/theme/liquid_glass.dart';
import 'package:smart_curtain_app/core/theme/aurora_glow.dart';
import 'package:smart_curtain_app/features/ai/presentation/bloc/voice_command_bloc.dart';
import 'package:smart_curtain_app/core/theme/app_typography.dart';
import 'package:smart_curtain_app/features/pairing/presentation/pages/osprey_add_device_page.dart';
import 'package:smart_curtain_app/features/scene/data/siri_shortcuts_service.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/siri_shortcuts_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/utils/scene_action_display.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/automation/automation_state.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/automation_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/automation/automation_detail_page.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/personal_info_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/settings_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/alexa_linking_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/google_assistant_linking_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/tap_to_run/tap_to_run_state.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_event.dart';
import 'package:smart_curtain_app/features/home/presentation/bloc/home_management_state.dart';
import 'package:smart_curtain_app/features/home/domain/entities/home_device_entity.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/CreateSceneTriggerPage.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/home_selector_sheet.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/home_management_page.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';
import 'package:smart_curtain_app/core/widgets/app_pull_refresh.dart';
import 'package:smart_curtain_app/core/widgets/email_avatar.dart';
import 'package:smart_curtain_app/core/theme/scene_style.dart';
import 'package:smart_curtain_app/core/notifications/message_center.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/app_mall_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/in_app_web_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/message_center_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/chat_tab.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/home_tab.dart'
    as home_tab;
import 'package:smart_curtain_app/features/scene/domain/entities/tap_to_run_scene_entity.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/create_tap_to_run_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/tap_to_run/manage_scenes_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/pages/scene_logs_page.dart';

class HomePage extends StatefulWidget {
  /// Tab mở đầu: 0 Home, 1 Scenes, 2 Chat, 3 Me. Sau đăng nhập vào thẳng Chat.
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Index các tab — giữ đồng bộ với _pages và _BrandBottomNav._items.
  static const int tabHome = 0;
  static const int tabScenes = 1;
  static const int tabChat = 2;
  static const int tabMe = 3;

  late int currentIndex = widget.initialIndex;
  static final GlobalKey<HomePageState> globalKey = GlobalKey<HomePageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Lift the native splash only once Home has painted its first frame, so the
    // hand-off is native splash → Home with no intermediate splash flash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _pages = [
      const home_tab.HomeTab(),
      const SceneTab(),
      ChatTab(onOpenScenes: () => setState(() => currentIndex = tabScenes)),
      const ProfileTab(),
    ];
  }

  /// Tappable home-name selector shown at the top-left edge of the Home and
  /// Scenes tabs.
  Widget _buildHomeGreeting(BuildContext context) {
    final state = context.watch<HomeManagementBloc>().state;
    return GestureDetector(
      onTap: state.homes.isNotEmpty ? () => _openHomeSelector(context) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              state.selectedHome?.name ?? 'My Home',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.unfold_more_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _openHomeSelector(BuildContext context) {
    final bloc = context.read<HomeManagementBloc>();
    final state = bloc.state;
    HomeSelectorDropdown.show(
      context: context,
      homes: state.homes,
      selectedHomeId: state.selectedHomeId,
      onSelect: (homeId) => bloc.add(SelectHomeEvent(homeId)),
      onManageHome: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeManagementPage()),
      ),
    );
  }

  PopupMenuEntry<String> _buildPopupItem(
      IconData icon, String title, String value) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenuSelected(BuildContext context, String value) async {
    switch (value) {
      case 'add-device':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OspreyAddDevicePage()),
        );
      case 'create-scene':
        _seedAutomationBloc(context);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateSceneTriggerPage()),
        );
    }
  }

  /// Bảo đảm AutomationBloc đã biết homeId trước khi mở trang tạo automation
  /// (create từ menu + khi chưa từng ghé tab Scenes).
  void _seedAutomationBloc(BuildContext context) {
    final bloc = context.read<AutomationBloc>();
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (bloc.state is AutomationInitial && homeId != null) {
      bloc.add(LoadAutomationsEvent(homeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: HomePageState.globalKey,
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Photo background (living room). A soft white scrim on top keeps
          // the cards and text readable over the image.
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(color: AppColors.background),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(60),
                    Colors.white.withAlpha(20),
                    Colors.white.withAlpha(55),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Subtle gold orb decoration
          Positioned(
            right: -100,
            bottom: screenHeight * 0.18,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentSubtle,
                    AppColors.background.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar - hidden on Me tab
                if (currentIndex != tabMe)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        // "My Home" greeting + selector at the top-left edge on
                        // the Home and Scenes tabs (where the brand icon used to
                        // be); other tabs just push the action button right.
                        if (currentIndex == tabHome ||
                            currentIndex == tabScenes)
                          Expanded(child: _buildHomeGreeting(context))
                        else
                          const Spacer(),
                        // Add button - blue circle on Home, black icon on Scene
                        if (currentIndex == tabScenes)
                          GestureDetector(
                            onTap: () {
                              _seedAutomationBloc(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CreateSceneTriggerPage(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.add,
                              color: AppColors.textPrimary,
                              size: 26,
                            ),
                          )
                        else
                          PopupMenuButton<String>(
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              side: const BorderSide(
                                color: AppColors.borderSubtle,
                              ),
                            ),
                            color: AppColors.surface,
                            elevation: 0,
                            shadowColor: AppColors.shadow,
                            onSelected: (value) =>
                                _onMenuSelected(context, value),
                            itemBuilder: (_) => [
                              _buildPopupItem(
                                Icons.devices_other_outlined,
                                AppL10n.of(context).addDevice,
                                'add-device',
                              ),
                              _buildPopupItem(
                                Icons.edit_square,
                                AppL10n.of(context).createScene,
                                'create-scene',
                              ),
                            ],
                            child: Container(
                              // Tight circle: just wraps the 22px "+" glyph.
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(50),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.textInverse,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Page content
                Expanded(
                  child: IndexedStack(index: currentIndex, children: _pages),
                ),
              ],
            ),
          ),

          // Aurora rim glow — covers the entire screen including safe areas.
          // Renders on top of all content; ignores touches.
          BlocBuilder<VoiceCommandBloc, VoiceCommandState>(
            builder: (context, vState) {
              final glowing =
                  vState is VoiceListening || vState is VoiceParsing;
              return Positioned.fill(
                child: IgnorePointer(
                  child: AuroraGlow(
                    style: vState is VoiceParsing
                        ? AuroraGlowStyle.intense
                        : AuroraGlowStyle.standard,
                    active: glowing,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _BrandBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}

/// Floating pill bottom navigation — distinct from the typical Material flat bar.
/// White rounded tile used in the automation card's illustration row
/// (clock trigger, device artwork, scene tag, ...).
class _AutomationTile extends StatelessWidget {
  final Widget child;

  const _AutomationTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _BrandBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BrandBottomNav({required this.currentIndex, required this.onTap});

  /// Nhãn lấy theo ngôn ngữ nên KHÔNG thể là `const` — dựng trong build.
  static List<(IconData, IconData, String)> _itemsFor(AppL10n l10n) => [
    (Icons.cottage_outlined, Icons.cottage, l10n.navHome),
    (Icons.auto_awesome_outlined, Icons.auto_awesome, l10n.navScenes),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, l10n.navChat),
    (Icons.person_outline_rounded, Icons.person_rounded, l10n.navMe),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(AppL10n.of(context));
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: LiquidGlass(
          radius: AppRadius.xl,
          fillColor: AppColors.glassFillStrong,
          child: SizedBox(
            height: 53,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final selected = currentIndex == i;
                final (outlined, filled, label) = items[i];
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    splashColor: AppColors.primary.withAlpha(15),
                    highlightColor: AppColors.primary.withAlpha(10),
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primarySubtle
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Icon(
                              selected ? filled : outlined,
                              size: 20,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: AppTypography.labelSmall.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontSize: 10,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// HomeTab is now in home_tab.dart (imported as home_tab)

// Scene Tab - with Automation / Tap-to-Run sub-tabs
class SceneTab extends StatefulWidget {
  const SceneTab({super.key});

  @override
  State<SceneTab> createState() => _SceneTabState();
}

class _SceneTabState extends State<SceneTab> {
  int _selectedSubTab = 0; // 0 = Automation, 1 = Tap-to-Run

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAutomationScenes();
      _loadTapToRunScenes();
    });
  }

  /// Nạp automation scenes — chỉ gọi khi đã có home. Repo đọc homeId từ
  /// TokenManager; dispatch sớm quá (trước khi homes load) sẽ dính lỗi
  /// "Vui long chon home truoc" và kẹt ở nút Retry.
  void _loadAutomationScenes() {
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (homeId != null) {
      // Also seeds AutomationBloc._homeId so create/edit from the detail page
      // knows which home to POST to.
      context.read<AutomationBloc>().add(LoadAutomationsEvent(homeId));
    }
  }

  void _loadTapToRunScenes() {
    final homeId = context.read<HomeManagementBloc>().state.selectedHomeId;
    if (homeId != null) {
      context.read<TapToRunBloc>().add(LoadTapToRunScenesEvent(homeId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeManagementBloc, HomeManagementState>(
      listenWhen: (prev, curr) =>
          prev.selectedHomeId != curr.selectedHomeId &&
          curr.status == HomeStatus.loaded,
      listener: (context, state) {
        _loadAutomationScenes();
        _loadTapToRunScenes();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Sub-tab row: Automation | Tap-to-Run | list icon
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedSubTab = 0),
                  child: Text(
                    AppL10n.of(context).automation,
                    style: TextStyle(
                      fontSize: _selectedSubTab == 0 ? 16 : 14,
                      fontWeight: _selectedSubTab == 0
                          ? FontWeight.bold
                          : FontWeight.w400,
                      color: _selectedSubTab == 0
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => setState(() => _selectedSubTab = 1),
                  child: Text(
                    AppL10n.of(context).tapToRun,
                    style: TextStyle(
                      fontSize: _selectedSubTab == 1 ? 16 : 14,
                      fontWeight: _selectedSubTab == 1
                          ? FontWeight.bold
                          : FontWeight.w400,
                      color: _selectedSubTab == 1
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  offset: const Offset(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  elevation: 4,
                  onSelected: (value) {
                    if (value == 'manage') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageScenesPage(),
                        ),
                      );
                    } else if (value == 'logs') {
                      final homeId = context
                          .read<HomeManagementBloc>()
                          .state
                          .selectedHomeId;
                      if (homeId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SceneLogsPage(homeId: homeId),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'manage',
                      height: 44,
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(AppL10n.of(context).manage, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logs',
                      height: 44,
                      child: Row(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(AppL10n.of(context).logs, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_horiz,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _selectedSubTab == 0
                  ? _buildAutomationContent()
                  : _buildTapToRunContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutomationContent() {
    return BlocBuilder<AutomationBloc, AutomationState>(
      builder: (context, state) {
        if (state is AutomationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AutomationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadAutomationScenes,
                  child: Text(AppL10n.of(context).retry),
                ),
              ],
            ),
          );
        }
        if (state is AutomationLoaded && state.automations.isNotEmpty) {
          return _buildAutomationList(context, state.automations);
        }
        return _buildEmptyAutomation();
      },
    );
  }

  /// Opens the rich automation editor. Pass an existing automation to edit, or
  /// null to create a new one. On return the AutomationBloc has already
  /// refreshed the list (it dispatches LoadAutomationsEvent after create/update).
  Future<void> _openAutomationDetail([
    AutomationSceneEntity? automation,
  ]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AutomationDetailPage(automation: automation),
      ),
    );
  }

  Widget _buildEmptyAutomation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sync, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            AppL10n.of(context).automationEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => _openAutomationDetail(),
            child: Text(
              AppL10n.of(context).createScene,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTapToRunContent() {
    return BlocConsumer<TapToRunBloc, TapToRunState>(
      listener: (context, state) {
        if (state is TapToRunExecuteResult) {
          _showExecuteResultDialog(context, state).then((_) {
            // Reload scenes to restore TapToRunLoaded state
            if (mounted) _loadTapToRunScenes();
          });
        }
      },
      builder: (context, state) {
        if (state is TapToRunLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TapToRunError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadTapToRunScenes(),
                  child: Text(AppL10n.of(context).retry),
                ),
              ],
            ),
          );
        }

        final scenes = state is TapToRunLoaded
            ? state.scenes
            : state is TapToRunExecuting
            ? state.scenes
            : state is TapToRunExecuteResult
            ? state.scenes
            : <TapToRunSceneEntity>[];

        if (scenes.isEmpty) {
          return _buildEmptyTapToRun();
        }

        // Nút "Add to Siri" nổi góc dưới phải, chỉ hiện trên iOS.
        return Stack(
          children: [
            _buildTapToRunList(context, scenes, state),
            if (GetIt.instance<SiriShortcutsService>().isSupported)
              PositionedDirectional(
                end: 16,
                // Đỉnh thanh navigation = safe area + padding 8 + cao 53 = 61,
                // nên 20 cho nút nằm hẳn trong vùng nav bar.
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: _AddToSiriButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => SiriShortcutsPage(scenes: scenes),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTapToRun() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            AppL10n.of(context).tapToRunEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () => _navigateToCreateTapToRun(),
            child: Text(
              AppL10n.of(context).createScene,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTapToRunList(
    BuildContext context,
    List<TapToRunSceneEntity> scenes,
    TapToRunState state,
  ) {
    return AppPullRefresh(
      onRefresh: () async {
        _loadTapToRunScenes();
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: GridView.builder(
        // Chừa chỗ cho thanh navigation nổi + nút Add to Siri phía trên nó,
        // để thẻ scene cuối cùng không bị che.
        padding: const EdgeInsets.only(bottom: 150),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Cell height cut to ~2/3, then nudged +~5px (ratio 1.65 → 1.58).
          childAspectRatio: 1.4,
        ),
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return _TapToRunCard(
            scene: scene,
            onTap: () {
              context.read<TapToRunBloc>().add(
                ExecuteTapToRunSceneEvent(scene.id),
              );
            },
            onMore: () => _navigateToEditTapToRun(scene),
          );
        },
      ),
    );
  }

  Future<void> _showExecuteResultDialog(
    BuildContext context,
    TapToRunExecuteResult state,
  ) async {
    // Scene vừa chạy — tra theo sceneId trong state; `.first` sẽ sai khi
    // home có nhiều scene hoặc 2 lượt execute xen kẽ.
    TapToRunSceneEntity? scene;
    for (final s in state.scenes) {
      if (s.id == state.sceneId) {
        scene = s;
        break;
      }
    }
    scene ??= state.scenes.isNotEmpty ? state.scenes.first : null;
    final sceneName = scene?.name ?? AppL10n.of(context).scene;
    final actions = scene?.actions ?? [];

    final homeState = context.read<HomeManagementBloc>().state;
    final devices = homeState.devices;
    // Tên chức năng cho action chỉ có dpId (scene tạo ở nơi khác).
    final dpNames = await resolveDpNames(actions: actions, devices: devices);
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                sceneName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Error message if failed
            if (state.status == 'FAILURE' && actions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(
                  state.details.isNotEmpty ? state.details : AppL10n.of(context).executionFailed,
                  style: TextStyle(fontSize: 15, color: Colors.red.shade400),
                  textAlign: TextAlign.center,
                ),
              ),
            // Actions list
            if (actions.isNotEmpty)
              ...actions.map((action) {
                String title;
                String subtitle;
                String? asset;
                switch (action.actionType) {
                  case 'DEVICE_CONTROL':
                    // Dòng trên: chức năng + giá trị. Dòng dưới: tên thiết bị
                    // HIỆN TẠI (snapshot trong action sai sau khi rename).
                    title = actionFunctionLabel(action, dpNames);
                    final live = deviceOfAction(action, devices);
                    subtitle =
                        live?.displayName ?? action.deviceName ?? AppL10n.of(context).device;
                    if (live?.isCurtainTrack ?? false) {
                      asset = kCurtainTrackAsset;
                    }
                  case 'DELAY':
                    title = AppL10n.of(context).delay;
                    final m = action.executorProperty?['minutes'] ?? 0;
                    final s = action.executorProperty?['seconds'] ?? 0;
                    subtitle = m > 0 ? '${m}m ${s}s' : '${s}s';
                  case 'SCENE_RUN':
                    title = AppL10n.of(context).runScene;
                    subtitle = action.deviceName ?? '';
                  default:
                    title = action.actionType;
                    subtitle = '';
                }
                final isSuccess = state.status == 'SUCCESS';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        padding:
                            asset != null ? const EdgeInsets.all(6) : null,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: asset != null
                            ? Image.asset(
                                asset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.devices_other,
                                  size: 20,
                                  color: Colors.grey.shade500,
                                ),
                              )
                            : Icon(
                                Icons.devices_other,
                                size: 20,
                                color: Colors.grey.shade500,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess ? Colors.green : Colors.red,
                        size: 22,
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            // OK button
            const Divider(height: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppL10n.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateTapToRun() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTapToRunPage()),
    );
    if (result == true && mounted) {
      _loadTapToRunScenes();
    }
  }

  void _navigateToEditTapToRun(TapToRunSceneEntity scene) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTapToRunPage(existingScene: scene),
      ),
    );
    if (result == true && mounted) {
      _loadTapToRunScenes();
    }
  }

  Widget _buildAutomationList(
    BuildContext context,
    List<AutomationSceneEntity> automations,
  ) {
    return AppPullRefresh(
      onRefresh: () async {
        _loadAutomationScenes();
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: automations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final automation = automations[index];
          return Dismissible(
            key: Key('automation_${automation.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsetsDirectional.only(end: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await AppDialog.confirm(
                context,
                title: AppL10n.of(context).deleteScene,
                message: AppL10n.of(context)
                    .deleteConfirmNamed(automation.name),
                confirmText: AppL10n.of(context).delete,
                destructive: true,
              );
            },
            onDismissed: (_) {
              context.read<AutomationBloc>().add(
                DeleteAutomationEvent(automation.id),
              );
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openAutomationDetail(automation),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name pinned to the top-left corner + chevron top-right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                automation.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                AppL10n.of(context).taskCount(automation.actions.length),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ],
                    ),

                    // Breathing room — the Tuya card is roughly double height.
                    const SizedBox(height: 34),

                    // Illustration: trigger (clock) → action tiles, + toggle.
                    Row(
                      children: [
                        const _AutomationTile(
                          child: Icon(
                            Icons.watch_later,
                            size: 28,
                            color: Color(0xFF42A5F5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_right_alt_rounded,
                            size: 24,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        ..._automationActionTiles(
                          automation,
                          context.read<HomeManagementBloc>().state.devices,
                        ),
                        const Spacer(),
                        Transform.scale(
                          scale: 0.82,
                          child: Switch(
                            value: automation.enabled,
                            onChanged: (v) {
                              context.read<AutomationBloc>().add(
                                ToggleAutomationEvent(automation.id, v),
                              );
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF2ECC71),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Action tiles for the automation card illustration row: curtain-track
  /// artwork per device action, tag for scene runs, hourglass for delays.
  /// Caps at 3 tiles with a "+n" overflow chip.
  List<Widget> _automationActionTiles(
    AutomationSceneEntity automation,
    List<HomeDeviceEntity> devices,
  ) {
    bool isCurtain(String? entityId) {
      for (final d in devices) {
        if (d.deviceId == entityId || d.id == entityId) {
          return d.isCurtainTrack;
        }
      }
      return false;
    }

    final tiles = <Widget>[];
    var shown = 0;
    for (final action in automation.actions) {
      if (shown == 3) break;
      final Widget child;
      switch (action.actionType) {
        case 'DEVICE_CONTROL':
          child = isCurtain(action.entityId)
              ? Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    'assets/icons/curtain_track.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.curtains_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : const Icon(
                  Icons.devices_other,
                  size: 22,
                  color: AppColors.textSecondary,
                );
        case 'SCENE_RUN':
          child = const Icon(Icons.sell, size: 22, color: Color(0xFF2BB673));
        case 'DELAY':
          child = const Icon(
            Icons.hourglass_bottom,
            size: 22,
            color: AppColors.primary,
          );
        default:
          child = Icon(
            Icons.settings_remote_outlined,
            size: 22,
            color: Colors.grey.shade500,
          );
      }
      tiles.add(
        Padding(
          padding: EdgeInsetsDirectional.only(start: shown == 0 ? 0 : 6),
          child: _AutomationTile(child: child),
        ),
      );
      shown++;
    }
    final rest = automation.actions.length - shown;
    if (rest > 0) {
      tiles.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6),
          child: _AutomationTile(
            child: Text(
              '+$rest',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }
    return tiles;
  }
}

/// Khối đen vuông góc + icon Siri thật, nổi ở góc dưới phải tab Tap-to-Run.
/// Chỉ dựng trên iOS.
class _AddToSiriButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddToSiriButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      // Bo nhẹ cho bớt gắt, vẫn giữ dáng vuông.
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        // Bản nửa cỡ nhân thêm 30%: cao ~26.
        child:  Padding(
          padding: EdgeInsets.fromLTRB(8, 5, 9, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/icons/siri_orb.png'),
                width: 16,
                height: 16,
              ),
              SizedBox(width: 6),
              Text(
                AppL10n.of(context).addToSiri,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapToRunCard extends StatelessWidget {
  final TapToRunSceneEntity scene;
  final VoidCallback onTap; // tap body → execute
  final VoidCallback onMore; // tap "..." → edit

  const _TapToRunCard({
    required this.scene,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final (cardColor, cardIcon) = SceneStyle.decode(scene.icon, scene.id);
    final lighterColor = Color.lerp(cardColor, Colors.white, 0.15)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lighterColor, cardColor],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: scene icon + ... menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Scene icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cardIcon, color: Colors.white, size: 22),
                ),
                // "..." → edit scene
                GestureDetector(
                  onTap: onMore,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Scene name
            Text(
              scene.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Task count
            Text(
              AppL10n.of(context).taskCount(scene.actions.length),
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mall Tab
class MallTab extends StatelessWidget {
  const MallTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          // Top right "..." button
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 16, top: 8),
              child: Icon(
                Icons.more_horiz,
                size: 24,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const Spacer(flex: 2),
          // Building illustration
          Icon(
            Icons.apartment_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppL10n.of(context).storeUnderPreparation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'HOME_PAGE_NOT_DESIGN',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = GetIt.instance<TokenManager>();
    final displayName = tokenManager.getDisplayName();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Top right icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
                child: Icon(
                  Icons.settings_outlined,
                  size: 24,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Avatar + Name
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
              );
            },
            child: Row(
              children: [
                // Default avatar: eagle logo
                EmailAvatar(
                  email: tokenManager.getEmailSync(),
                  fallback: displayName,
                  size: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Third-Party Services card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppL10n.of(context).thirdPartyServices,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlexaLinkingPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/alexa_logo.png',
                              width: 44,
                              height: 44,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppL10n.of(context).alexa,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const GoogleAssistantLinkingPage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/google_assistant_logo.png',
                              width: 44,
                              height: 44,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppL10n.of(context).googleAssistant,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu card: Home Management / Message Center / FAQ & Feedback / App Mall
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuRow(
                  Icons.home_outlined,
                  AppL10n.of(context).homeManagement,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeManagementPage(),
                    ),
                  ),
                ),
                _divider(),
                AnimatedBuilder(
                  animation: GetIt.instance<MessageCenter>()..ensureLoaded(),
                  builder: (context, _) => _buildMenuRow(
                    Icons.chat_outlined,
                    AppL10n.of(context).messageCenter,
                    hasNotification:
                        GetIt.instance<MessageCenter>().unreadCount > 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MessageCenterPage(),
                      ),
                    ),
                  ),
                ),
                _divider(),
                _buildMenuRow(
                  Icons.help_outline,
                  AppL10n.of(context).faqFeedback,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InAppWebPage(
                        title: AppL10n.of(context).faqFeedback,
                        url: 'https://osprey.life/pages/contact',
                      ),
                    ),
                  ),
                ),
                _divider(),
                _buildMenuRow(
                  Icons.storefront_outlined,
                  AppL10n.of(context).appMall,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppMallPage()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    IconData icon,
    String title, {
    bool hasNotification = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsetsDirectional.only(end: 8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }
}
