import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/common/enums/store_color.dart';

import '../../helpers/either_expectations.dart';
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

  group('softDeleteUser', () {
    test('성공 시 right(null)을 반환한다', () async {
      when(() => mockUserDs.softDeleteUser(any())).thenAnswer((_) async {});

      final result = await repository.softDeleteUser('user-123');

      expectRight(result);
      verify(() => mockUserDs.softDeleteUser('user-123')).called(1);
    });

    test('DataSource 실패 시 left를 반환한다', () async {
      when(() => mockUserDs.softDeleteUser(any()))
          .thenThrow(Exception('탈퇴 실패'));

      final result = await repository.softDeleteUser('user-123');

      expectLeft(result);
    });
  });
}
