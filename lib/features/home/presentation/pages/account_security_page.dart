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
        backgroundColor: const Color(0xFFF8F5F0),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title:  Text(
            AppL10n.of(context).accountAndSecurity,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        body: ListView(
          children: [
            _buildSection([
              _buildInfoItem(AppL10n.of(context).emailAddressLabel, email),
            ]),

            _buildSection([
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

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 16,
              color: Colors.grey.shade200,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title, {
    Color textColor = Colors.black87,
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
                style: TextStyle(fontSize: 15, color: textColor),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
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
