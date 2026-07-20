import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import 'manage_home_page.dart';

/// Tuya-style "Home Management" hub: lists every home the user has (tap one to
/// manage it), plus "Create a home" / "Join a home" actions.
class HomeManagementPage extends StatelessWidget {
  const HomeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Home Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          return ListView(
            children: [
              // ── All homes ──
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    for (var i = 0; i < state.homes.length; i++) ...[
                      if (i > 0)
                        Divider(
                            height: 1,
                            indent: 20,
                            color: Colors.grey.shade100),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageHomePage(
                              homeId: state.homes[i].id,
                              homeName: state.homes[i].name,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  state.homes[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.grey.shade400, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Create a home ──
              _ActionRow(
                label: 'Create a home',
                onTap: () => _showCreateHomeDialog(context),
              ),

              const SizedBox(height: 12),

              // ── Join a home ──
              _ActionRow(
                label: 'Join a home',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Joining a home by invite is coming soon.')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateHomeDialog(BuildContext context) async {
    final bloc = context.read<HomeManagementBloc>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Create a home',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Home name',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'Create',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    // Timezone omitted → bloc stamps the device's IANA zone automatically.
    bloc.add(CreateHomeEvent(name: name));
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
