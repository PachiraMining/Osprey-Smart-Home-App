import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/home_member_entity.dart';
import '../../domain/usecases/get_home_members.dart';
import '../../domain/usecases/get_rooms.dart';
import '../bloc/home_management_bloc.dart';
import '../bloc/home_management_event.dart';
import '../../data/city_catalog.dart';
import 'city_picker_page.dart';
import 'manage_rooms_page.dart';
import '../../../../core/theme/app_surfaces.dart';

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
  static const _link = Color(0xFF007AFF);
  static const _danger = Color(0xFFFF3B30);

  late String _name = widget.homeName;
  int? _roomCount;
  List<HomeMemberEntity> _members = const [];

  /// geoName hiển thị — giữ cục bộ để cập nhật ngay sau khi chọn thành phố,
  /// thay vì chờ trang được dựng lại với widget.geoName mới.
  String? _geoName;

  @override
  void initState() {
    super.initState();
    _geoName = widget.geoName;
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

  /// Chọn thành phố → ghi geoName + toạ độ. Toạ độ là điều kiện tiên quyết
  /// cho automation theo thời tiết.
  Future<void> _pickCity() async {
    final navigator = Navigator.of(context);
    final bloc = context.read<HomeManagementBloc>();
    final city = await navigator.push<CityEntry>(
      MaterialPageRoute(builder: (_) => const CityPickerPage()),
    );
    if (city == null || !mounted) return;
    final geoName = '${city.name}, ${city.country}';
    bloc.add(UpdateHomeEvent(
      homeId: widget.homeId,
      name: widget.homeName,
      geoName: geoName,
      latitude: city.latitude,
      longitude: city.longitude,
    ));
    setState(() => _geoName = geoName);
  }

  Future<void> _renameHome() async {
    final name = await AppDialog.prompt(
      context,
      title: AppL10n.of(context).homeName,
      initialValue: _name,
      hintText: AppL10n.of(context).enterHomeName,
      confirmText: AppL10n.of(context).save,
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
      title: AppL10n.of(context).deleteHome,
      message: AppL10n.of(context).deleteHomeConfirm(_name),
      confirmText: AppL10n.of(context).delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    context.read<HomeManagementBloc>().add(DeleteHomeEvent(widget.homeId));
    Navigator.of(context).pop();
  }

  void _notYet(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppL10n.of(context).featureComingSoonNamed(feature))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaces.pageBg,
      appBar: AppBar(
        backgroundColor: context.surfaces.pageBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: context.surfaces.textPrimary,
        title:  Text(
          AppL10n.of(context).homeSettings,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                _SettingsRow(
                  label: AppL10n.of(context).homeName,
                  value: _name,
                  onTap: _renameHome,
                ),
                _SettingsRow(
                  label: AppL10n.of(context).roomManagement,
                  value: _roomCount == null ? '' : AppL10n.of(context).roomCount(_roomCount!),
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
                  label: AppL10n.of(context).location,
                  value: (_geoName == null || _geoName!.isEmpty)
                      ? AppL10n.of(context).toBeSet
                      : _geoName!,
                  onTap: _pickCity,
                ),
                _SettingsRow(
                  label: AppL10n.of(context).managePermissions,
                  onTap: () => _notYet(AppL10n.of(context).managePermissions),
                ),
              ],
            ),
          ),
           _SectionHeader(AppL10n.of(context).homeMember),
          Container(
            color: context.surfaces.card,
            child: Column(
              children: [
                for (final member in _members)
                  _MemberRow(
                    member: member,
                    onTap: () => _notYet(AppL10n.of(context).memberDetails),
                  ),
                if (_members.isNotEmpty)
                  Divider(height: 1, indent: 20, color: context.surfaces.divider),
                InkWell(
                  onTap: () => _notYet(AppL10n.of(context).addMember),
                  child:  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        AppL10n.of(context).addMember,
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
            color: context.surfaces.card,
            child: InkWell(
              onTap: _deleteHome,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    AppL10n.of(context).deleteHome,
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
                style:  TextStyle(fontSize: 17, color: context.surfaces.textPrimary),
              ),
            ),
            if (value != null && value!.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: Text(
                  value!,
                  style: TextStyle(fontSize: 16, color: context.surfaces.textSecondary),
                ),
              ),
            Icon(Icons.chevron_right, color: context.surfaces.textMuted, size: 22),
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
        style: TextStyle(fontSize: 14, color: context.surfaces.textSecondary),
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
                    style:  TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: context.surfaces.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.surfaces.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              member.isPending ? AppL10n.of(context).pending : member.roleLabel,
              style: TextStyle(fontSize: 16, color: context.surfaces.textSecondary),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.surfaces.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
