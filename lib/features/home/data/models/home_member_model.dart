import '../../domain/entities/home_member_entity.dart';

class HomeMemberModel extends HomeMemberEntity {
  const HomeMemberModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.status,
    super.firstName,
    super.lastName,
    super.email,
  });

  factory HomeMemberModel.fromJson(Map<String, dynamic> json) {
    return HomeMemberModel(
      id: json['id'] is Map ? json['id']['id'] ?? '' : (json['id'] ?? ''),
      userId: json['userId'] is Map
          ? json['userId']['id'] ?? ''
          : (json['userId'] ?? ''),
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  /// Ghép hồ sơ user (`GET /api/user/{id}`) vào bản ghi thành viên.
  HomeMemberModel withProfile(Map<String, dynamic> user) => HomeMemberModel(
        id: id,
        userId: userId,
        role: role,
        status: status,
        firstName: user['firstName'] as String?,
        lastName: user['lastName'] as String?,
        email: user['email'] as String?,
      );
}
