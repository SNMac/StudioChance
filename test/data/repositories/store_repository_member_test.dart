import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/data/repositories/store_repository_impl.dart';
import 'package:studio_chance/common/exceptions/user_exceptions.dart';

import '../../helpers/fake_models.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

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

      expectRight(result);
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

      expectLeft(result);
    });
  });

  group('getStore 멤버 조회', () {
    test('멤버 사용자 문서를 네트워크 오류로 못 읽으면 멤버를 빼지 않고 실패한다', () async {
      // 깨진 문서만 건너뛴다 — 네트워크 오류까지 삼키면 멤버가 조용히 사라져 보인다
      when(
        () => mockStoreDataSource.getStore('store-123'),
      ).thenAnswer((_) async => fakeStoreModel);
      when(
        () => mockUserDataSource.getUser('user-123'),
      ).thenThrow(UserNetworkException(message: '오프라인'));

      final result = await repository.getStore('store-123');

      expect(expectLeft(result), isA<UserNetworkException>());
    });

    test('멤버 사용자 문서를 다른 이유로 못 읽으면 그 멤버만 빼고 조회한다', () async {
      when(
        () => mockStoreDataSource.getStore('store-123'),
      ).thenAnswer((_) async => fakeStoreModel);
      when(
        () => mockUserDataSource.getUser('user-123'),
      ).thenThrow(UserUnknownException(message: '파싱 실패'));

      final store = expectRight(await repository.getStore('store-123'))!;

      expect(store.memberInfos, isEmpty);
    });
  });
}
