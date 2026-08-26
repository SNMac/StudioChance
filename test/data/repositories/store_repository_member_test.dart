import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/data/data_sources/store_data_source.dart';
import 'package:studio_chance/data/data_sources/user_data_source.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

class MockStoreDataSource extends Mock implements StoreDataSource {}

class MockUserDataSource extends Mock implements UserDataSource {}

void main() {
  late StoreRepositoryImpl repository;
  late MockStoreDataSource mockStoreDataSource;
  late MockUserDataSource mockUserDataSource;

  setUp(() {
    mockStoreDataSource = MockStoreDataSource();
    mockUserDataSource = MockUserDataSource();
    repository = StoreRepositoryImpl(
      storeDataSource: mockStoreDataSource,
      userDataSource: mockUserDataSource,
    );
  });

  group('removeMember', () {
    test('StoreDataSource.removeMember에 storeId와 uid를 그대로 전달한다', () async {
      when(
        () => mockStoreDataSource.removeMember(any(), any()),
      ).thenAnswer((_) async {});

      final result = await repository.removeMember(
        storeId: 'store-123',
        uid: 'user-456',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => mockStoreDataSource.removeMember('store-123', 'user-456'),
      ).called(1);
    });

    test('DataSource가 예외를 던지면 left를 반환한다', () async {
      when(
        () => mockStoreDataSource.removeMember(any(), any()),
      ).thenThrow(Exception('삭제 실패'));

      final result = await repository.removeMember(
        storeId: 'store-123',
        uid: 'user-456',
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
