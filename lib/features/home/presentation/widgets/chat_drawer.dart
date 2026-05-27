import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/auth/token_manager.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../pages/personal_info_page.dart';
import '../pages/add_device_page.dart';
import '../../../scene/presentation/pages/tap_to_run/manage_scenes_page.dart';

/// Side drawer for [ChatHomePage].
///
/// The chat surface is the primary entry; this drawer provides access to the
/// legacy device-centric flows (now demoted from the home grid).
class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Osprey Life',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _Item(
                    icon: Icons.curtains,
                    label: 'Devices',
                    // HomePage owns the device grid + its required Scaffold,
                    // bottom nav, and Bloc context. Pushing the inner HomeTab
                    // standalone breaks text rendering (no Material ancestor).
                    onTap: () => _push(context, const HomePage()),
                  ),
                  _Item(
                    icon: Icons.touch_app_outlined,
                    label: 'Tap-to-Run scenes',
                    onTap: () => _push(context, const ManageScenesPage()),
                  ),
                  _Item(
                    icon: Icons.add_circle_outline,
                    label: 'Add a curtain',
                    onTap: () => _push(context, const AddDevicePage()),
                  ),
                  const Divider(height: 24),
                  _Item(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () => _push(context, const PersonalInfoPage()),
                  ),
                  _Item(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _push(context, const SettingsPage()),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _Item(
              icon: Icons.logout,
              label: 'Sign out',
              onTap: () => _confirmSignOut(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer first
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  static Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will be returned to the welcome screen. Cached devices stay on your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await GetIt.instance<TokenManager>().clearTokens();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacementNamed(context, '/');
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
