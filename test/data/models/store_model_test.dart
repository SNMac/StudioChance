import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data.dart';

void main() {
  group('StoreModel.toEntity', () {
    test('spaceOptions가 비어있으면 그대로 빈 리스트를 반환한다 (legacy fallback 없음)', () {
      final store = fakeStoreModel.toEntity(
        memberInfos: [],
        waitingMemberInfos: [],
      );

      expect(store.spaceOptions, isEmpty);
    });
  });
}
