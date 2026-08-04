import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_curtain_app/core/widgets/app_popup.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../../../../core/auth/token_manager.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/app_surfaces.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = GetIt.instance<TokenManager>();
    final email = tokenManager.getEmailSync() ?? '';

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        }
        if (state is AuthFailure) {
          AppPopup.error(context, title: AppL10n.of(context).error, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.surfaces.pageBg,
        appBar: AppBar(
          backgroundColor: context.surfaces.sheet,
          elevation: 0.5,
          leading: IconButton(
            icon:  Icon(Icons.arrow_back_ios, size: 20, color: context.surfaces.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title:  Text(
            AppL10n.of(context).accountAndSecurity,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.surfaces.textPrimary,
            ),
          ),
        ),
        body: ListView(
          children: [
            _buildSection(context, [
              _buildInfoItem(context, AppL10n.of(context).emailAddressLabel, email),
            ]),

            _buildSection(context, [
              _buildNavItem(
                context,
                AppL10n.of(context).deleteAccount,
                textColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: context.surfaces.card,
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 16,
              color: context.surfaces.divider,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:  TextStyle(fontSize: 15, color: context.surfaces.textPrimary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: context.surfaces.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title, {
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 15,
                    color: textColor ?? context.surfaces.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: context.surfaces.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final result = await AppDialog.confirmWithInput(
      context,
      title: AppL10n.of(context).deleteAccount,
      message: AppL10n.of(context).deleteAccountWarning,
      messageColor: Colors.red,
      hintText: AppL10n.of(context).reasonOptional,
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
    if (!result.ok || !context.mounted) return;
    context.read<AuthBloc>().add(DeleteAccountEvent(reason: result.text));
  }
}
