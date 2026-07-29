import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';

/// Một thành viên của home.
///
/// API `SmartHomeMember` chỉ trả `userId`; [displayName] và [email] được tra
/// thêm từ `GET /api/user/{userId}` nên có thể rỗng nếu tra thất bại.
class HomeMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String role;
  final String status;
  final String? firstName;
  final String? lastName;
  final String? email;

  const HomeMemberEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
    this.email,
  });

  bool get isOwner => role.toUpperCase() == 'OWNER';

  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Tên hiển thị: họ tên nếu có, lùi về phần trước @ của email, cuối cùng là
  /// nhãn chung để không bao giờ hiện UUID cho người dùng.
  String get displayName {
    final full = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (full.isNotEmpty) return full;
    final mail = email;
    if (mail != null && mail.contains('@')) return mail.split('@').first;
    return 'Member';
  }

  /// Chữ cái trên avatar tròn.
  String get initial {
    final name = displayName;
    return name.isEmpty ? '?' : name.characters.first.toUpperCase();
  }

  /// Nhãn vai trò theo đúng cách Tuya hiển thị.
  String get roleLabel => switch (role.toUpperCase()) {
        'OWNER' => 'Home Owner',
        'ADMIN' || 'ADMINISTRATOR' => 'Administrator',
        _ => 'Member',
      };

  @override
  List<Object?> get props =>
      [id, userId, role, status, firstName, lastName, email];
}
