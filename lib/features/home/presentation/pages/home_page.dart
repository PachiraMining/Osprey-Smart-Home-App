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

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentIndex = 1;
  static final GlobalKey<HomePageState> globalKey = GlobalKey<HomePageState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeTab(),
      const AutomationTab(),
      const SmartTab(),
      const ProfileTab(),
    ];
  }

  // Hàm hiển thị popup menu
  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                context,
                icon: Icons.devices_other_outlined,
                title: 'Add Device',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Add Device page with BLE
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDevicePage()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.edit_square,
                title: 'Create Scene',
                onTap: () async {
                  Navigator.pop(context);
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
                      builder: (_) =>
                          CreateScenePage(scheduleData: triggerData),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.add_box_outlined,
                title: 'Add Favorite Cards',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Add Favorite Cards page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Favorite Cards clicked')),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.qr_code_scanner_outlined,
                title: 'Quét',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to QR Scanner page
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Quét clicked')));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomePageState.globalKey,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDBE8FF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          "Nhà của tôi ...",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, size: 26),
                          onPressed: () {
                            // TODO: QR Scanner action
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 30),
                          onPressed: () =>
                              _showAddMenu(context), // GỌI POPUP MENU
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (currentIndex == 0)
                      Row(
                        children: [
                          const Text(
                            "Favorites",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.dehaze_rounded, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DeviceManagementPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: currentIndex == 0 ? 10 : 20),
              Expanded(
                child: IndexedStack(index: currentIndex, children: _pages),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Nhà',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Thông minh',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.smart_toy_outlined),
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
              ],
            ),
            label: 'Smart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}

// AutomationTab - BLoC-based
class AutomationTab extends StatelessWidget {
  const AutomationTab({super.key});

  String _formatRepeatMode(SceneEntity scene) {
    switch (scene.repeatMode) {
      case 'once':
        return 'Mot lan';
      case 'daily':
        return 'Hang ngay';
      case 'weekly':
        final days = scene.daysOfWeek;
        if (days == '1,2,3,4,5') return 'Thu 2 - Thu 6';
        if (days == '6,7') return 'Cuoi tuan';
        return 'T ${days.replaceAll(',', ', T ')}';
      default:
        return scene.repeatMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                "Tu dong hoa",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              Text(
                "Cham de chay",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<SceneBloc, SceneState>(
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
                          child: const Text('Thu lai'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is SceneLoaded && state.scenes.isNotEmpty) {
                  return _buildSceneList(context, state.scenes);
                }
                return _buildEmptyState(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneList(BuildContext context, List<SceneEntity> scenes) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SceneBloc>().add(LoadScenesEvent());
      },
      child: ListView.separated(
        itemCount: scenes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xoa scene?'),
                  content: Text('Ban co chac muon xoa "${scene.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Huy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Xoa', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) {
              context.read<SceneBloc>().add(DeleteSceneEvent(scene.id));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.withOpacity(0.15),
                    child: const Icon(Icons.access_time, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${scene.time} | ${_formatRepeatMode(scene)} | ${scene.action.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 14,
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

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome,
          size: 180,
          color: Colors.grey.withOpacity(0.4),
        ),
        const SizedBox(height: 30),
        const Text(
          "Dieu khien nhieu thiet bi bang mot lan cham hoac\nbang loa ho tro AI thong qua lenh thoai",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateScenePage(scheduleData: triggerData),
                  ),
                );
              },
              child: const Text(
                "Create Scene",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// Các tab khác giữ nguyên
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class SmartTab extends StatelessWidget {
  const SmartTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Smart Tab"));
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Tôi"));
}
