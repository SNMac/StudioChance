import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

import '../../helpers/fake_data.dart';

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

  group('getStoreByInviteCode 만료 검증', () {
    test('서버 시각이 만료 시간 이전이면 점포를 반환한다', () async {
      final createdAt = DateTime(2026, 1, 1, 0, 0);
      final storeModel = fakeStoreModel.copyWith(
        // memberById를 비워 _fetchMembersWithRoles가 mockUserDs.getUser를
        // 호출하지 않도록 한다 (이 테스트는 만료 검증 로직만 검증한다).
        memberById: const {},
        inviteInfoModel: InviteInfoModel(
          inviteCode: 'ABC123',
          createdAt: createdAt,
        ),
      );
      when(
        () => mockStoreDs.getStoreByInviteCode(any()),
      ).thenAnswer((_) async => storeModel);
      // 기기 시각(DateTime.now())은 미래로 조작되었더라도, 서버 시각이
      // 만료 시각(createdAt + 15분) 이전이면 유효해야 한다.
      when(
        () => mockStoreDs.getServerTime(),
      ).thenAnswer((_) async => createdAt.add(const Duration(minutes: 10)));

      final result = await repository.getStoreByInviteCode('ABC123');

      result.fold(
        (error) => fail('유효한 초대 코드인데 실패를 반환했다: $error'),
        (store) => expect(store?.inviteInfo?.inviteCode, 'ABC123'),
      );
    });

    test(
      '서버 시각이 만료 시간을 지났으면 left(StoreInviteCodeExpiredException)을 반환한다',
      () async {
        final createdAt = DateTime(2026, 1, 1, 0, 0);
        final storeModel = fakeStoreModel.copyWith(
          inviteInfoModel: InviteInfoModel(
            inviteCode: 'ABC123',
            createdAt: createdAt,
          ),
        );
        when(
          () => mockStoreDs.getStoreByInviteCode(any()),
        ).thenAnswer((_) async => storeModel);
        when(
          () => mockStoreDs.getServerTime(),
        ).thenAnswer((_) async => createdAt.add(const Duration(minutes: 20)));

        final result = await repository.getStoreByInviteCode('ABC123');

        // StoreValidationException과 구분되어야 한다. 같은 타입이면 사용자에게
        // '잠시 후 다시 시도해 주세요'라는 틀린 안내가 나간다.
        result.fold(
          (error) => expect(error, isA<StoreInviteCodeExpiredException>()),
          (_) => fail('만료된 초대 코드인데 성공을 반환했다'),
        );
      },
    );
  });
}
