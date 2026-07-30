import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import 'manage_rooms_page.dart';

class ManageHomePage extends StatefulWidget {
  final String homeId;
  final String homeName;

  const ManageHomePage({
    super.key,
    required this.homeId,
    required this.homeName,
  });

  @override
  State<ManageHomePage> createState() => _ManageHomePageState();
}

class _ManageHomePageState extends State<ManageHomePage> {
  late final TextEditingController _nameController;

  static const _blue = Color(0xFF1B4332);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.homeName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<HomeManagementBloc>().add(
          UpdateHomeEvent(homeId: widget.homeId, name: name),
        );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppL10n.of(context).deleteHome,
      message:
          AppL10n.of(context).deleteHomeConfirm(widget.homeName),
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );

    if (confirmed && mounted) {
      context
          .read<HomeManagementBloc>()
          .add(DeleteHomeEvent(widget.homeId));
      // Pop to root so the home list refreshes
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeManagementBloc, HomeManagementState>(
      listenWhen: (prev, curr) => curr.mutationStatus != prev.mutationStatus,
      listener: (context, state) {
        if (state.mutationStatus == MutationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppL10n.of(context).anErrorOccurred),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppL10n.of(context).homeManagement),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppL10n.of(context).homeName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppL10n.of(context).enterHomeName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppL10n.of(context).save, style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.door_front_door_outlined,
                    color: Colors.black87),
                title: Text(AppL10n.of(context).roomManagement),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<HomeManagementBloc>(),
                      child: ManageRoomsPage(homeId: widget.homeId),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const Spacer(),
              OutlinedButton(
                onPressed: _confirmDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppL10n.of(context).deleteHome,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
