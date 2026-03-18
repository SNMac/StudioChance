import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/store_member_info_model.dart';
import 'package:studio_chance/data/models/store_model.dart';
import 'package:studio_chance/data/models/user_store_info_model.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

import '../../helpers/fake_data.dart';

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

// mocktail fallback 등록용
class FakeStoreModel extends Fake implements StoreModel {}

class FakeStoreMemberInfoModel extends Fake implements StoreMemberInfoModel {}

class FakeUserStoreInfoModel extends Fake implements UserStoreInfoModel {}

class FakeInviteInfoModel extends Fake implements InviteInfoModel {}

void main() {
  late StoreRepositoryImpl repository;
  late MockStoreDataSource mockStoreDataSource;
  late MockUserDataSource mockUserDataSource;

  setUpAll(() {
    registerFallbackValue(FakeStoreModel());
    registerFallbackValue(FakeStoreMemberInfoModel());
    registerFallbackValue(FakeUserStoreInfoModel());
    registerFallbackValue(UserRole.admin);
  });

  setUp(() {
    mockStoreDataSource = MockStoreDataSource();
    mockUserDataSource = MockUserDataSource();
    repository = StoreRepositoryImpl(
      storeDataSource: mockStoreDataSource,
      userDataSource: mockUserDataSource,
    );
  });

  group('updateStore', () {
    test('StoreDataSource와 UserDataSource가 올바른 파라미터로 호출된다', () async {
      when(
        () => mockStoreDataSource.updateStore(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockUserDataSource.updateStoreInfo(any(), any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.updateStore(
        store: fakeStore,
        uid: fakeUser.id,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isRight(), true);

      // 점포 문서 업데이트 호출 확인
      final capturedStoreArgs = verify(
        () => mockStoreDataSource.updateStore(
          captureAny(),
          captureAny(),
        ),
      ).captured;
      expect(capturedStoreArgs[0], fakeStore.id);
      final storeData = capturedStoreArgs[1] as Map<String, dynamic>;
      expect(storeData.containsKey('name'), true);
      expect(storeData.containsKey('address'), true);
      expect(storeData.containsKey('addressDetail'), true);
      expect(storeData.containsKey('addressGuide'), true);
      expect(storeData.containsKey('priceSettingsModel'), true);
      expect(storeData['name'], fakeStore.name);

      // 유저 점포 정보 업데이트 호출 확인
      final capturedUserArgs = verify(
        () => mockUserDataSource.updateStoreInfo(
          captureAny(),
          captureAny(),
          captureAny(),
        ),
      ).captured;
      expect(capturedUserArgs[0], fakeUser.id);
      expect(capturedUserArgs[1], fakeStore.id);
      final userStoreData = capturedUserArgs[2] as Map<String, dynamic>;
      expect(userStoreData['color'], StoreColor.blue.name);
      expect(userStoreData['memo'], '새 메모');
    });

    test('StoreDataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockStoreDataSource.updateStore(any(), any()),
      ).thenThrow(Exception('Firestore 오류'));

      final result = await repository.updateStore(
        store: fakeStore,
        uid: fakeUser.id,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isLeft(), true);
      verifyNever(
        () => mockUserDataSource.updateStoreInfo(any(), any(), any()),
      );
    });

    test('UserDataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockStoreDataSource.updateStore(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockUserDataSource.updateStoreInfo(any(), any(), any()),
      ).thenThrow(Exception('유저 정보 업데이트 오류'));

      final result = await repository.updateStore(
        store: fakeStore,
        uid: fakeUser.id,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isLeft(), true);
    });
  });
}
