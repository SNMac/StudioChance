import 'package:flutter_test/flutter_test.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';

import '../../helpers/fake_entities.dart';

void main() {
  group('sortedMemberInfos', () {
    StoreMemberInfo member(String id, String nickname, UserRole role) =>
        StoreMemberInfo(
          user: fakeUser.copyWith(id: id, nickname: nickname),
          role: role,
        );

    test('관리자 → 스태프 → 뷰어 순이고, 같은 역할은 이름 가나다순이다', () {
      final store = fakeStore.copyWith(
        memberInfos: [
          member('v', '가뷰어', UserRole.viewer),
          member('s2', '하스태프', UserRole.staff),
          member('a', '홍관리', UserRole.admin),
          member('s1', '김스태프', UserRole.staff),
        ],
      );

      expect(store.sortedMemberInfos.map((m) => m.user.id), [
        'a',
        's1',
        's2',
        'v',
      ]);
    });
  });
}
