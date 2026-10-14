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
}
