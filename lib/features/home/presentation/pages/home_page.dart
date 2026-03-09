// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/CreateSceneTriggerPage.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/create_scene_page.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/add_device_page.dart';
import 'package:smart_curtain_app/features/device/presentation/pages/device_management_page.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_bloc.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_event.dart';
import 'package:smart_curtain_app/features/scene/presentation/bloc/scene_state.dart';
import 'package:smart_curtain_app/features/scene/domain/entities/scene_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/auth/token_manager.dart';
import 'package:smart_curtain_app/features/home/presentation/pages/personal_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static const _bgColor = Color(0xFFD5E3EC);
  static const _accentBlue = Color(0xFF2196F3);

  int currentIndex = 0;
  static final GlobalKey<HomePageState> globalKey = GlobalKey<HomePageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeTab(),
      const SceneTab(),
      const MallTab(),
      const ProfileTab(),
    ];
  }

  PopupMenuEntry<String> _buildPopupItem(IconData icon, String title) {
    return PopupMenuItem<String>(
      value: title,
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
      case 'Add Device':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDevicePage()),
        );
      case 'Create Scene':
        final triggerData = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateSceneTriggerPage(),
          ),
        );
        if (triggerData == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateScenePage(scheduleData: triggerData),
          ),
        );
      case 'Scan':
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: HomePageState.globalKey,
      extendBody: true,
      body: Stack(
        children: [
          // Background color
          Container(
            width: double.infinity,
            height: double.infinity,
            color: _bgColor,
          ),

          // Furniture background image at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: screenHeight * 0.4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/splash_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  // Top fade gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_bgColor, Color(0x00D5E3EC)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar - hidden on Mall tab
                if (currentIndex != 2 && currentIndex != 3)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        // Avatar - eagle logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/eagle_logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Add button - blue circle on Home, black icon on Scene
                        if (currentIndex == 1)
                          GestureDetector(
                            onTap: () async {
                              final triggerData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateSceneTriggerPage(),
                                ),
                              );
                              if (triggerData == null) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreateScenePage(scheduleData: triggerData),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 30,
                            ),
                          )
                        else
                          PopupMenuButton<String>(
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.black.withAlpha(40),
                            onSelected: (value) => _onMenuSelected(context, value),
                            itemBuilder: (_) => [
                              _buildPopupItem(Icons.devices_other_outlined, 'Add Device'),
                              _buildPopupItem(Icons.edit_square, 'Create Scene'),
                              _buildPopupItem(Icons.qr_code_scanner_outlined, 'Scan'),
                            ],
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: _accentBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
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
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            enableFeedback: false,
            onTap: (i) => setState(() => currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined),
                activeIcon: Icon(Icons.check_box),
                label: 'Scene',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Mall',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle),
                label: 'Me',
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// Home Tab - "No devices" state
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Device placeholder icon
            Icon(
              Icons.devices_other_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No devices',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            // Add Device button
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDevicePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Device',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Scene Tab - with Automation / Tap-to-Run sub-tabs
class SceneTab extends StatefulWidget {
  const SceneTab({super.key});

  @override
  State<SceneTab> createState() => _SceneTabState();
}

class _SceneTabState extends State<SceneTab> {
  int _selectedSubTab = 0; // 0 = Automation, 1 = Tap-to-Run

  String _formatRepeatMode(SceneEntity scene) {
    switch (scene.repeatMode) {
      case 'once':
        return 'Once';
      case 'daily':
        return 'Daily';
      case 'weekly':
        final days = scene.daysOfWeek;
        if (days == '1,2,3,4,5') return 'Mon - Fri';
        if (days == '6,7') return 'Weekend';
        return 'D ${days.replaceAll(',', ', D ')}';
      default:
        return scene.repeatMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  'Automation',
                  style: TextStyle(
                    fontSize: _selectedSubTab == 0 ? 20 : 16,
                    fontWeight: _selectedSubTab == 0 ? FontWeight.bold : FontWeight.w400,
                    color: _selectedSubTab == 0 ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() => _selectedSubTab = 1),
                child: Text(
                  'Tap-to-Run',
                  style: TextStyle(
                    fontSize: _selectedSubTab == 1 ? 20 : 16,
                    fontWeight: _selectedSubTab == 1 ? FontWeight.bold : FontWeight.w400,
                    color: _selectedSubTab == 1 ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.assignment_outlined, size: 22, color: Colors.grey.shade600),
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
    );
  }

  Widget _buildAutomationContent() {
    return BlocBuilder<SceneBloc, SceneState>(
      builder: (context, state) {
        if (state is SceneLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SceneError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<SceneBloc>().add(LoadScenesEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is SceneLoaded && state.scenes.isNotEmpty) {
          return _buildSceneList(context, state.scenes);
        }
        return _buildEmptyAutomation();
      },
    );
  }

  Widget _buildEmptyAutomation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sync,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Home automation saves your time and effort by automating routine tasks.',
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
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () async {
              final triggerData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSceneTriggerPage(),
                ),
              );
              if (triggerData == null) return;
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateScenePage(scheduleData: triggerData),
                ),
              );
            },
            child: const Text(
              'Create Scene',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTapToRunContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app_outlined,
          size: 64,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Create a task and tap it to run. This enables easy control of your smart devices.',
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
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () async {
              final triggerData = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateSceneTriggerPage(),
                ),
              );
              if (triggerData == null) return;
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateScenePage(scheduleData: triggerData),
                ),
              );
            },
            child: const Text(
              'Create Scene',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSceneList(BuildContext context, List<SceneEntity> scenes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SceneBloc>().add(LoadScenesEvent());
      },
      child: ListView.separated(
        itemCount: scenes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return Dismissible(
            key: Key('scene_${scene.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete scene?'),
                  content: Text('Are you sure you want to delete "${scene.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) {
              context.read<SceneBloc>().add(DeleteSceneEvent(scene.id));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF2196F3).withAlpha(30),
                    child: const Icon(Icons.access_time, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${scene.time} | ${_formatRepeatMode(scene)} | ${scene.action.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: scene.enabled,
                    onChanged: (v) {
                      context.read<SceneBloc>().add(
                        ToggleSceneEvent(scene.id, v),
                      );
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
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
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: Icon(Icons.more_horiz, size: 24, color: Colors.grey.shade400),
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
              'The store is under preparation, please stay tuned.',
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
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
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
    final firstLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

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
              Icon(Icons.qr_code_scanner, size: 24, color: Colors.grey.shade700),
              const SizedBox(width: 20),
              Icon(Icons.settings_outlined, size: 24, color: Colors.grey.shade700),
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/eagle_logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 28),
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
                const Text(
                  'Third-Party Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/alexa_logo.png',
                            width: 44,
                            height: 44,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Alexa',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/google_assistant_logo.png',
                            width: 44,
                            height: 44,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Google Assistant',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu items card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuRow(Icons.home_outlined, 'Home Management'),
                _divider(),
                _buildMenuRow(Icons.chat_bubble_outline, 'Message Center', hasNotification: true),
                _divider(),
                _buildMenuRow(Icons.help_outline, 'FAQ & Feedback'),
                _divider(),
                _buildMenuRow(Icons.shopping_bag_outlined, 'App Mall'),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, {bool hasNotification = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (hasNotification)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
        ],
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
