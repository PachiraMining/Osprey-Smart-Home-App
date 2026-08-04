import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import 'home_settings_page.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Tuya-style "Home Management" hub: lists every home the user has (tap one to
/// manage it), plus "Create a home" / "Join a home" actions.
class HomeManagementPage extends StatelessWidget {
  const HomeManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.sheet,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios,
              size: 20, color: context.surfaces.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppL10n.of(context).homeManagement,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.surfaces.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          return ListView(
            children: [
              // ── All homes ──
              Container(
                color: context.surfaces.card,
                child: Column(
                  children: [
                    for (var i = 0; i < state.homes.length; i++) ...[
                      if (i > 0)
                        Divider(
                            height: 1,
                            indent: 20,
                            color: context.surfaces.divider),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeSettingsPage(
                              homeId: state.homes[i].id,
                              homeName: state.homes[i].name,
                              geoName: state.homes[i].geoName,
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
                                  style:  TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: context.surfaces.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: context.surfaces.textMuted, size: 24),
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
                label: AppL10n.of(context).createAHome,
                onTap: () => _showCreateHomeDialog(context),
              ),

              const SizedBox(height: 12),

              // ── Join a home ──
              _ActionRow(
                label: AppL10n.of(context).joinAHome,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(AppL10n.of(context).joiningAHomeByInviteIsComingSoon)),
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
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).createAHome,
      hintText: AppL10n.of(context).homeName2,
      confirmText: AppL10n.of(context).create,
    );
    if (name == null) return;
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
      color: context.surfaces.card,
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
