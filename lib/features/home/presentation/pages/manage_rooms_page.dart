import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_curtain_app/core/widgets/app_dialog.dart';

import '../../domain/entities/room_entity.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../bloc/home_management_state.dart';
import '../../../../core/theme/app_surfaces.dart';

/// Danh sách phòng: mỗi dòng kèm số thiết bị, nút sắp xếp lại ở góc phải, và
/// "Add Room" nằm cuối danh sách (không phải dấu + trên thanh tiêu đề).
class ManageRoomsPage extends StatefulWidget {
  final String homeId;

  const ManageRoomsPage({super.key, required this.homeId});

  @override
  State<ManageRoomsPage> createState() => _ManageRoomsPageState();
}

class _ManageRoomsPageState extends State<ManageRoomsPage> {
  static const _link = Color(0xFF007AFF);

  /// Đang ở chế độ kéo sắp xếp — lúc này chạm vào dòng KHÔNG mở đổi tên nữa.
  bool _reordering = false;

  /// Thứ tự đang kéo, giữ cục bộ để danh sách không giật trong lúc chờ server.
  List<RoomEntity>? _draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        title: Text(l10n.roomManagement),
        backgroundColor: context.surfaces.pageBg,
        foregroundColor: context.surfaces.textPrimary,
        elevation: 0,
        actions: [
          if (_reordering)
            TextButton(
              onPressed: () => setState(() {
                _reordering = false;
                _draft = null;
              }),
              child: Text(l10n.done,
                  style: const TextStyle(color: _link, fontSize: 17)),
            )
          else
            IconButton(
              tooltip: l10n.sort,
              icon: const Icon(Icons.sort),
              onPressed: () => setState(() => _reordering = true),
            ),
        ],
      ),
      body: BlocBuilder<HomeManagementBloc, HomeManagementState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading && state.rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = _draft ?? state.rooms;
          if (rooms.isEmpty) return _empty(l10n);

          // Số thiết bị mỗi phòng tính ngay ở client từ roomId — backend không
          // có sẵn trường đếm, và cũng không cần gọi thêm API.
          final counts = <String, int>{};
          for (final d in state.devices) {
            final id = d.roomId;
            if (id != null) counts[id] = (counts[id] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 32),
            children: [
              Container(
                color: context.surfaces.card,
                child: _reordering
                    ? _reorderableList(rooms, counts)
                    : Column(
                        children: [
                          for (var i = 0; i < rooms.length; i++)
                            _roomRow(rooms[i], counts[rooms[i].id] ?? 0,
                                last: i == rooms.length - 1),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Container(
                color: context.surfaces.card,
                child: InkWell(
                  onTap: _showCreateDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Text(
                      l10n.addRoom,
                      style: const TextStyle(fontSize: 17, color: _link),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(AppL10n l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.meeting_room_outlined,
                size: 64, color: context.surfaces.textMuted),
            const SizedBox(height: 12),
            Text(l10n.noRoomsYet,
                style:  TextStyle(color: context.surfaces.textSecondary, fontSize: 16)),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _showCreateDialog,
              child: Text(l10n.addRoom,
                  style: const TextStyle(color: _link, fontSize: 16)),
            ),
          ],
        ),
      );

  Widget _reorderableList(List<RoomEntity> rooms, Map<String, int> counts) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: true,
      onReorder: (oldIndex, newIndex) => _onReorder(rooms, oldIndex, newIndex),
      children: [
        for (var i = 0; i < rooms.length; i++)
          _roomRow(rooms[i], counts[rooms[i].id] ?? 0,
              last: i == rooms.length - 1, key: ValueKey(rooms[i].id)),
      ],
    );
  }

  void _onReorder(List<RoomEntity> rooms, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final next = [...rooms];
    next.insert(newIndex, next.removeAt(oldIndex));
    setState(() => _draft = next);

    // Ghi thứ tự mới cho từng phòng bị đổi chỗ. PUT là full-replace nên phải
    // gửi kèm tên, nếu không tên phòng sẽ bị xoá.
    final bloc = context.read<HomeManagementBloc>();
    for (var i = 0; i < next.length; i++) {
      if (next[i].sortOrder == i) continue;
      bloc.add(UpdateRoomEvent(
        homeId: widget.homeId,
        roomId: next[i].id,
        name: next[i].name,
        icon: next[i].icon,
        sortOrder: i,
      ));
    }
  }

  Widget _roomRow(RoomEntity room, int deviceCount,
      {required bool last, Key? key}) {
    final row = Padding(
      padding: const EdgeInsetsDirectional.only(start: 20),
      child: Container(
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFECECEC), width: 0.5)),
        ),
        padding: const EdgeInsetsDirectional.only(end: 20, top: 18, bottom: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(fontSize: 17, color: context.surfaces.textPrimary),
              ),
            ),
            if (!_reordering) ...[
              Text(
                AppL10n.of(context).deviceCount(deviceCount),
                style:  TextStyle(fontSize: 15, color: context.surfaces.textSecondary),
              ),
              const SizedBox(width: 6),
               Icon(Icons.chevron_right, color: context.surfaces.textMuted, size: 22),
            ],
          ],
        ),
      ),
    );

    if (_reordering) return KeyedSubtree(key: key!, child: row);

    return Dismissible(
      key: ValueKey(room.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(room.name),
      onDismissed: (_) => context.read<HomeManagementBloc>().add(
            DeleteRoomEvent(homeId: widget.homeId, roomId: room.id),
          ),
      background: Container(
        color: Colors.red,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(room),
        child: row,
      ),
    );
  }

  Future<bool?> _confirmDelete(String roomName) {
    return AppDialog.confirm(
      context,
      title: AppL10n.of(context).deleteRoom,
      message: AppL10n.of(context).deleteConfirmNamed(roomName),
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
  }

  Future<void> _showCreateDialog() async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).addRoom,
      hintText: AppL10n.of(context).roomName,
      confirmText: AppL10n.of(context).add,
    );
    if (name == null || !mounted) return;
    context
        .read<HomeManagementBloc>()
        .add(CreateRoomEvent(homeId: widget.homeId, name: name));
  }

  Future<void> _showEditDialog(RoomEntity room) async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).renameRoom,
      initialValue: room.name,
      hintText: AppL10n.of(context).roomName,
      confirmText: AppL10n.of(context).save,
    );
    if (name == null || !mounted) return;
    context.read<HomeManagementBloc>().add(
          UpdateRoomEvent(
            homeId: widget.homeId,
            roomId: room.id,
            name: name,
            icon: room.icon,
            // giữ nguyên thứ tự cũ, nếu không phòng bị nhảy về đầu
            sortOrder: room.sortOrder,
          ),
        );
  }
}
