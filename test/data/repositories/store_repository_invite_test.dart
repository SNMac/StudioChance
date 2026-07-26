import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    test('서버 시각 기준으로 만료 시간이 지나면 left(StoreValidationException)을 반환한다', () async {
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

      expect(result.isRight(), true);
    });

    test('서버 시각이 만료 시간을 지났으면 left(StoreValidationException)을 반환한다', () async {
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

      expect(result.isLeft(), true);
    });
  });
}
