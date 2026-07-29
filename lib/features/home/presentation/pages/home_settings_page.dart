import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/home_member_entity.dart';
import '../../domain/usecases/get_home_members.dart';
import '../../domain/usecases/get_rooms.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import 'manage_rooms_page.dart';

/// Cài đặt của MỘT home: tên, phòng, vị trí, phân quyền, thành viên, xoá nhà.
class HomeSettingsPage extends StatefulWidget {
  final String homeId;
  final String homeName;

  /// Vị trí đã lưu (`geoName`); rỗng → hiện "To Be Set".
  final String? geoName;

  const HomeSettingsPage({
    super.key,
    required this.homeId,
    required this.homeName,
    this.geoName,
  });

  @override
  State<HomeSettingsPage> createState() => _HomeSettingsPageState();
}

class _HomeSettingsPageState extends State<HomeSettingsPage> {
  static const _pageBg = Color(0xFFF2F4F7);
  static const _link = Color(0xFF007AFF);
  static const _danger = Color(0xFFFF3B30);

  late String _name = widget.homeName;
  int? _roomCount;
  List<HomeMemberEntity> _members = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Phòng và thành viên của home ĐANG XEM — không đọc từ
  /// [HomeManagementBloc] vì state đó thuộc home đang được chọn ở tab Home.
  Future<void> _load() async {
    final rooms = await GetIt.instance<GetRooms>()(widget.homeId);
    final members = await GetIt.instance<GetHomeMembers>()(widget.homeId);
    if (!mounted) return;
    setState(() {
      rooms.fold((_) {}, (list) => _roomCount = list.length);
      members.fold((_) {}, (list) => _members = list);
    });
  }

  Future<void> _renameHome() async {
    final name = await AppDialog.prompt(
      context,
      title: 'Home Name',
      initialValue: _name,
      hintText: 'Enter home name',
      confirmText: 'Save',
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    final trimmed = name.trim();
    context
        .read<HomeManagementBloc>()
        .add(UpdateHomeEvent(homeId: widget.homeId, name: trimmed));
    setState(() => _name = trimmed);
  }

  Future<void> _deleteHome() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete Home',
      message: 'Are you sure you want to delete "$_name"? '
          'This action cannot be undone.',
      confirmText: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    context.read<HomeManagementBloc>().add(DeleteHomeEvent(widget.homeId));
    Navigator.of(context).pop();
  }

  void _notYet(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text(
          'Home Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _SettingsRow(
                  label: 'Home Name',
                  value: _name,
                  onTap: _renameHome,
                ),
                _SettingsRow(
                  label: 'Room Management',
                  value: _roomCount == null ? '' : '$_roomCount Room(s)',
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ManageRoomsPage(homeId: widget.homeId),
                      ),
                    );
                    _load(); // số phòng có thể đã đổi
                  },
                ),
                _SettingsRow(
                  label: 'Location',
                  value: (widget.geoName == null || widget.geoName!.isEmpty)
                      ? 'To Be Set'
                      : widget.geoName!,
                  onTap: () => _notYet('Location'),
                ),
                _SettingsRow(
                  label: 'Manage Permissions',
                  onTap: () => _notYet('Manage Permissions'),
                ),
              ],
            ),
          ),
          const _SectionHeader('Home Member'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                for (final member in _members)
                  _MemberRow(
                    member: member,
                    onTap: () => _notYet('Member details'),
                  ),
                if (_members.isNotEmpty)
                  Divider(height: 1, indent: 20, color: Colors.grey.shade200),
                InkWell(
                  onTap: () => _notYet('Add Member'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add Member',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _link,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.white,
            child: InkWell(
              onTap: _deleteHome,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'Delete Home',
                    style: TextStyle(fontSize: 17, color: _danger),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hàng "nhãn — giá trị ›" của nhóm cài đặt.
class _SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsRow({required this.label, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
            ),
            if (value != null && value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Dải tiêu đề nhóm trên nền xám của trang.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final HomeMemberEntity member;
  final VoidCallback onTap;

  const _MemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8D6E63),
              ),
              child: Text(
                member.initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    member.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              member.isPending ? 'Pending' : member.roleLabel,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}
