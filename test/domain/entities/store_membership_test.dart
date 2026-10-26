import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';

void main() {
  const membership = StoreMembership(
    roleByUid: {'admin-1': UserRole.admin, 'staff-1': UserRole.staff},
  );

  test('roleOf는 멤버의 역할을, 멤버가 아니면 null을 돌려준다', () {
    expect(membership.roleOf('admin-1'), UserRole.admin);
    expect(membership.roleOf('outsider'), isNull);
  });

  test('hasMembersOtherThan은 주어진 사람 말고 멤버가 있는지 알려준다', () {
    expect(membership.hasMembersOtherThan('admin-1'), isTrue);
    expect(
      const StoreMembership(roleByUid: {'admin-1': UserRole.admin})
          .hasMembersOtherThan('admin-1'),
      isFalse,
    );
  });
}
