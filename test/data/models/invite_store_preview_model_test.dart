import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/models/invite_store_preview_model.dart';

void main() {
  group('InviteStorePreviewModel', () {
    test('Callable 응답 JSON을 파싱한다', () {
      final model = InviteStorePreviewModel.fromJson({
        'storeId': 'store-1',
        'storeName': '테스트 점포',
        'address': '경기 오산시 경기대로285번길 26',
        'addressDetail': '3층',
        'adminName': '홍길동',
      });

      expect(model.storeId, 'store-1');
      expect(model.storeName, '테스트 점포');
      expect(model.adminName, '홍길동');
    });

    test('toEntity가 모든 필드를 그대로 옮긴다', () {
      const model = InviteStorePreviewModel(
        storeId: 'store-1',
        storeName: '테스트 점포',
        address: '주소',
        addressDetail: '상세',
        adminName: '홍길동',
      );

      final entity = model.toEntity();

      expect(entity.storeId, 'store-1');
      expect(entity.storeName, '테스트 점포');
      expect(entity.address, '주소');
      expect(entity.addressDetail, '상세');
      expect(entity.adminName, '홍길동');
    });
  });

  group('inviteLookupFailureOf', () {
    test('expired는 만료 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('expired'),
        isA<StoreInviteCodeExpiredException>(),
      );
    });

    test('rateLimited는 요청 한도 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('rateLimited'),
        isA<StoreResourceExhaustedException>(),
      );
    });

    test('invalidCode는 검증 예외로 매핑된다', () {
      expect(
        inviteLookupFailureOf('invalidCode'),
        isA<StoreValidationException>(),
      );
    });

    test('notFound와 알 수 없는 사유는 null이다 (코드 없음으로 처리)', () {
      expect(inviteLookupFailureOf('notFound'), isNull);
      expect(inviteLookupFailureOf('그런거없음'), isNull);
      expect(inviteLookupFailureOf(null), isNull);
    });
  });
}
