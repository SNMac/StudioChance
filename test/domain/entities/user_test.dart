import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/user_role.dart';

import '../../helpers/fake_entities.dart';

void main() {
  group('점포별 정보 조회', () {
    test('소속 점포면 그 점포의 정보와 역할을 돌려준다', () {
      expect(fakeUser.storeInfoOf('store-123')?.name, '테스트 점포');
      expect(fakeUser.roleIn('store-123'), UserRole.admin);
    });

    test('소속되지 않은 점포면 null을 돌려준다', () {
      expect(fakeUser.storeInfoOf('other-store'), isNull);
      expect(fakeUser.roleIn('other-store'), isNull);
    });
  });

  group('승인 대기 점포', () {
    final applicant = fakeUser.copyWith(
      storeInfos: [
        ...fakeUser.storeInfos,
        fakeUser.storeInfos.first.copyWith(
          id: 'store-pending',
          role: UserRole.staff,
          isPending: true,
        ),
      ],
    );

    test('아직 멤버가 아니므로 역할이 없는 것으로 본다', () {
      // 표시용 정보(별칭·색상)는 그대로 조회된다
      expect(applicant.storeInfoOf('store-pending'), isNotNull);
      expect(applicant.roleIn('store-pending'), isNull);
    });

    test('멤버 점포 목록에서 빠진다', () {
      expect(applicant.memberStoreInfos.map((info) => info.id), ['store-123']);
    });

    // select가 매번 바뀐 값으로 보면 사용자 정보가 다시 불릴 때마다 불필요하게
    // 다시 그린다 (storeInfos처럼 같은 사용자 객체면 같은 값이어야 한다)
    test('같은 사용자에게서 꺼낸 멤버 점포 목록은 서로 같다', () {
      expect(applicant.memberStoreInfos == applicant.memberStoreInfos, isTrue);
    });
  });

  group('displayName', () {
    test('닉네임이 있으면 닉네임을 쓴다', () {
      expect(fakeUser.displayName, '닉네임');
    });

    test('닉네임이 없으면(가입 직후) 소셜 계정 이름을 쓴다', () {
      expect(fakeUser.copyWith(nickname: null).displayName, '테스트 유저');
    });
  });
}
