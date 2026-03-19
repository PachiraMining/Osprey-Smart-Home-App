import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';

class ManageRoomsPage extends StatelessWidget {
  final String homeId;

  const ManageRoomsPage({super.key, required this.homeId});

  static const _blue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Room Management'),
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
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.meeting_room_outlined,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text(
                    'No rooms yet',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap + to add a new room',
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
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
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
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete "$roomName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Room Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<HomeManagementBloc>().add(
                      CreateRoomEvent(homeId: homeId, name: name),
                    );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String roomId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Room'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Room Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<HomeManagementBloc>().add(
                      UpdateRoomEvent(
                        homeId: homeId,
                        roomId: roomId,
                        name: name,
                      ),
                    );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
