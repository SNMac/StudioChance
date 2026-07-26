import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/data_sources/auth_data_source.dart';
import 'package:studio_chance/data/data_sources/notification_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/enums/store_color.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

class MockNotificationDataSource extends Mock
    implements NotificationDataSource {}

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
      when(
        () => mockUserDs.updateStoreInfo(any(), any(), any()),
      ).thenAnswer((invocation) async {
        capturedData =
            invocation.positionalArguments[2] as Map<String, dynamic>;
      });

      final result = await repository.updateStoreInfo(
        uid: 'user-123',
        storeId: 'store-123',
        color: StoreColor.green,
      );

      expect(result.isRight(), true);
      expect(capturedData?['color'], 'GREEN');
    });
  });
}
