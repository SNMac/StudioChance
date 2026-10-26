import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/common/enums/store_color.dart';

import '../../helpers/either_expectations.dart';
import '../../helpers/fake_entities.dart';
import '../../helpers/mocks.dart';

void main() {
  late UserRepositoryImpl repository;
  late MockAuthDataSource mockAuthDs;
  late MockUserDataSource mockUserDs;
  late MockNotificationDataSource mockNotificationDs;

  setUp(() {
    mockAuthDs = MockAuthDataSource();
    mockUserDs = MockUserDataSource();
    mockNotificationDs = MockNotificationDataSource();
    repository = UserRepositoryImpl(
      authDataSource: mockAuthDs,
      userDataSource: mockUserDs,
      notificationDataSource: mockNotificationDs,
    );
  });

  group('updateStoreInfo', () {
    test('color는 대문자 JSON 값(예: GREEN)으로 저장된다', () async {
      Map<String, dynamic>? capturedData;
      when(() => mockUserDs.updateStoreInfo(any(), any(), any()))
          .thenAnswer((invocation) async {
            capturedData =
                invocation.positionalArguments[2] as Map<String, dynamic>;
          });

      final result = await repository.updateStoreInfo(
        uid: 'user-123',
        storeId: 'store-123',
        color: StoreColor.green,
      );

      expectRight(result);
      expect(capturedData?['color'], 'GREEN');
    });
  });

  group('markAccountDeleted', () {
    test('닉네임을 남기도록 DataSource를 호출한다', () async {
      when(
        () => mockUserDs.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.markAccountDeleted(fakeUser);

      expectRight(result);
      verify(() => mockUserDs.markAccountDeleted('user-123', nickname: '닉네임'))
          .called(1);
    });

    test('닉네임이 없으면 이름을 남긴다', () async {
      when(
        () => mockUserDs.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async {});

      await repository.markAccountDeleted(fakeUser.copyWith(nickname: null));

      verify(
        () => mockUserDs.markAccountDeleted('user-123', nickname: '테스트 유저'),
      ).called(1);
    });

    test('DataSource 실패 시 left를 반환한다', () async {
      when(
        () => mockUserDs.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      ).thenThrow(Exception('계정 삭제 실패'));

      final result = await repository.markAccountDeleted(fakeUser);

      expectLeft(result);
    });
  });
}
