import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';

class ManageRoomsPage extends StatelessWidget {
  final String homeId;

  const ManageRoomsPage({super.key, required this.homeId});

  static const _blue = Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppL10n.of(context).roomManagement),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = state.rooms;

          if (rooms.isEmpty) {
            return  Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.meeting_room_outlined,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text(
                    AppL10n.of(context).noRoomsYet,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppL10n.of(context).tapPlusToAddRoom,
                    style: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 56),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Dismissible(
                key: ValueKey(room.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, room.name),
                onDismissed: (_) {
                  context.read<HomeManagementBloc>().add(
                        DeleteRoomEvent(homeId: homeId, roomId: room.id),
                      );
                },
                background: Container(
                  color: Colors.red,
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.meeting_room_outlined, color: _blue),
                  ),
                  title: Text(room.name),
                  trailing: const Icon(Icons.edit_outlined,
                      size: 20, color: Colors.black45),
                  onTap: () => _showEditDialog(context, room.id, room.name),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String roomName) {
    return AppDialog.confirm(
      context,
      title: AppL10n.of(context).deleteRoom,
      message: AppL10n.of(context).deleteConfirmNamed(roomName),
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).addRoom,
      hintText: AppL10n.of(context).roomName,
      confirmText: AppL10n.of(context).add,
    );
    if (name == null || !context.mounted) return;
    context.read<HomeManagementBloc>().add(
          CreateRoomEvent(homeId: homeId, name: name),
        );
  }

  Future<void> _showEditDialog(
      BuildContext context, String roomId, String currentName) async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).renameRoom,
      initialValue: currentName,
      hintText: AppL10n.of(context).roomName,
      confirmText: AppL10n.of(context).save,
    );
    if (name == null || !context.mounted) return;
    context.read<HomeManagementBloc>().add(
          UpdateRoomEvent(
            homeId: homeId,
            roomId: roomId,
            name: name,
          ),
        );
  }
}
