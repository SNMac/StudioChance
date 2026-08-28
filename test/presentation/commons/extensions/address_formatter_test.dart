import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/presentation/commons/extensions/address_formatter.dart';

import '../../../helpers/fake_entities.dart';

void main() {
  group('formatShortAddress', () {
    test('도로명 주소는 시/군/구와 도로명만 남긴다', () {
      expect(
        formatShortAddress('경기 오산시 경기대로285번길 26', '101호'),
        '오산시 경기대로285번길',
      );
    });

    test('토큰이 2개면 그대로 이어 붙인다', () {
      expect(formatShortAddress('경기 오산시', ''), '경기 오산시');
    });

    test('토큰이 1개면 그대로 반환한다', () {
      expect(formatShortAddress('오산시', ''), '오산시');
    });

    test('주소가 비어 있고 상세 주소만 있으면 상세 주소를 쓴다', () {
      expect(formatShortAddress('', '직접 입력한 주소'), '직접 입력한 주소');
    });

    test('주소와 상세 주소가 모두 비어 있으면 안내 문구를 쓴다', () {
      expect(formatShortAddress('', ''), '주소 검색');
    });
  });

  group('StoreAddressFormatter', () {
    test('Store도 점포 폼과 같은 규칙으로 줄인다', () {
      final store = fakeStore.copyWith(
        address: '서울 강남구 테헤란로 1',
        addressDetail: '101호',
      );

      expect(store.formattedAddress, '강남구 테헤란로');
    });
  });
}
