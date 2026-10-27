import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/invite_store_preview_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late StoreRepositoryImpl repository;
  late MockStoreDataSource mockStoreDs;
  late MockUserDataSource mockUserDs;

  setUp(() {
    mockStoreDs = MockStoreDataSource();
    mockUserDs = MockUserDataSource();
    repository = StoreRepositoryImpl(
      storeDataSource: mockStoreDs,
      userDataSource: mockUserDs,
    );
  });

  group('getStoreByInviteCode', () {
    const preview = InviteStorePreviewModel(
      storeId: 'store-1',
      storeName: '테스트 점포',
      address: '경기 오산시 경기대로285번길 26',
      addressDetail: '3층',
      adminName: '홍길동',
    );

    test('조회 결과를 엔티티로 감싸 반환한다', () async {
      when(() => mockStoreDs.lookupInviteCode('AB3D9F'))
          .thenAnswer((_) async => preview);

      final result = await repository.getStoreByInviteCode('AB3D9F');

      expect(expectRight(result)?.storeId, 'store-1');
    });

    test('코드가 없으면 right(null)을 반환한다', () async {
      when(() => mockStoreDs.lookupInviteCode('NOTFND'))
          .thenAnswer((_) async => null);

      final result = await repository.getStoreByInviteCode('NOTFND');

      expect(expectRight(result), isNull);
    });

    test('DataSource가 던진 예외는 left로 감싼다', () async {
      when(() => mockStoreDs.lookupInviteCode('EXPIRD'))
          .thenThrow(StoreInviteCodeExpiredException(message: '만료된 초대 코드입니다.'));

      final result = await repository.getStoreByInviteCode('EXPIRD');

      expect(expectLeft(result), isA<StoreInviteCodeExpiredException>());
    });
  });

  group('issueInviteCode', () {
    test('재발급 여부를 그대로 넘기고 발급 결과를 돌려준다', () async {
      when(() => mockStoreDs.issueInviteCode('store-1', forceRegenerate: true))
          .thenAnswer((_) async => const InviteInfoModel(inviteCode: 'AB3D9F'));

      final result = await repository.issueInviteCode(
        'store-1',
        forceRegenerate: true,
      );

      expect(expectRight(result).inviteCode, 'AB3D9F');
    });

    test('서버가 거절하면 Left로 감싼다', () async {
      when(() => mockStoreDs.issueInviteCode('store-1'))
          .thenThrow(StorePermissionDeniedException(message: '권한 없음'));

      final result = await repository.issueInviteCode('store-1');

      expect(expectLeft(result), isA<StorePermissionDeniedException>());
    });
  });
}
