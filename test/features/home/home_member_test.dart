import 'package:flutter_test/flutter_test.dart';
import 'package:smart_curtain_app/features/home/data/models/home_member_model.dart';

void main() {
  group('HomeMemberModel.fromJson', () {
    test('bóc id lồng của userId (UserId object) và giữ role/status', () {
      final m = HomeMemberModel.fromJson(const {
        'id': 'row-1',
        'userId': {'entityType': 'USER', 'id': 'user-1'},
        'role': 'OWNER',
        'status': 'ACTIVE',
      });
      expect(m.id, 'row-1');
      expect(m.userId, 'user-1');
      expect(m.isOwner, isTrue);
      expect(m.isPending, isFalse);
    });

    test('thiếu role/status → mặc định MEMBER/ACTIVE, không ném', () {
      final m = HomeMemberModel.fromJson(const {'id': 'r', 'userId': 'u'});
      expect(m.role, 'MEMBER');
      expect(m.roleLabel, 'Member');
      expect(m.status, 'ACTIVE');
    });
  });

  group('hiển thị', () {
    HomeMemberModel base() => HomeMemberModel.fromJson(const {
          'id': 'r',
          'userId': 'u',
          'role': 'OWNER',
          'status': 'ACTIVE',
        });

    test('ghép hồ sơ user → tên đầy đủ + avatar chữ cái đầu', () {
      final m = base().withProfile(const {
        'firstName': 'Nguyễn Việt',
        'lastName': 'Lâm',
        'email': 'lam.nguyen@dracaena.io',
      });
      expect(m.displayName, 'Nguyễn Việt Lâm');
      expect(m.email, 'lam.nguyen@dracaena.io');
      expect(m.initial, 'N');
      expect(m.roleLabel, 'Home Owner');
    });

    test('không có tên → lùi về phần trước @ của email', () {
      final m = base().withProfile(const {'email': 'lam.nguyen@dracaena.io'});
      expect(m.displayName, 'lam.nguyen');
      expect(m.initial, 'L');
    });

    test('tra hồ sơ thất bại → KHÔNG bao giờ lộ UUID ra UI', () {
      final m = base();
      expect(m.displayName, 'Member');
      expect(m.displayName, isNot(contains(m.userId)));
      expect(m.initial, 'M');
    });

    test('ADMIN hiển thị là Administrator', () {
      final m = HomeMemberModel.fromJson(const {
        'id': 'r',
        'userId': 'u',
        'role': 'ADMIN',
        'status': 'PENDING',
      });
      expect(m.roleLabel, 'Administrator');
      expect(m.isPending, isTrue);
    });
  });
}
