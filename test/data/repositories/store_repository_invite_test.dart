import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/invite_store_preview_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

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
      when(
        () => mockStoreDs.lookupInviteCode('AB3D9F'),
      ).thenAnswer((_) async => preview);

      final result = await repository.getStoreByInviteCode('AB3D9F');

      result.fold(
        (error) => fail('성공을 기대했으나 실패: $error'),
        (value) => expect(value?.storeId, 'store-1'),
      );
    });

    test('코드가 없으면 right(null)을 반환한다', () async {
      when(
        () => mockStoreDs.lookupInviteCode('NOTFND'),
      ).thenAnswer((_) async => null);

      final result = await repository.getStoreByInviteCode('NOTFND');

      result.fold(
        (error) => fail('성공을 기대했으나 실패: $error'),
        (value) => expect(value, isNull),
      );
    });

    test('DataSource가 던진 예외는 left로 감싼다', () async {
      when(
        () => mockStoreDs.lookupInviteCode('EXPIRD'),
      ).thenThrow(StoreInviteCodeExpiredException(message: '만료된 초대 코드입니다.'));

      final result = await repository.getStoreByInviteCode('EXPIRD');

      result.fold(
        (error) => expect(error, isA<StoreInviteCodeExpiredException>()),
        (_) => fail('실패를 기대했으나 성공'),
      );
    });
  });
}
