import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/data/repositories/store_repository_impl.dart';

import '../../helpers/fake_data.dart';
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

  group('updateStore', () {
    test('점포 문서만 고치고, 멤버별 값인 색상·메모(사용자 문서)는 쓰지 않는다', () async {
      when(
        () => mockStoreDataSource.updateStore(
          any(),
          any(),
          isUnchanged: any(named: 'isUnchanged'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateStore(
        original: fakeStore,
        store: fakeStore,
      );

      expectRight(result);

      final capturedStoreArgs = verify(
        () => mockStoreDataSource.updateStore(
          captureAny(),
          captureAny(),
          isUnchanged: captureAny(named: 'isUnchanged'),
        ),
      ).captured;
      expect(capturedStoreArgs[0], fakeStore.id);
      final storeData = capturedStoreArgs[1] as Map<String, dynamic>;
      expect(storeData.containsKey('name'), true);
      expect(storeData.containsKey('address'), true);
      expect(storeData.containsKey('addressDetail'), true);
      expect(storeData.containsKey('addressGuide'), true);
      expect(storeData.containsKey('spaceOptions'), true);
      expect(storeData['name'], fakeStore.name);

      verifyNever(
        () => mockUserDataSource.updateStoreInfo(any(), any(), any()),
      );
    });

    test('StoreDataSource 실패 시 left(exception)를 반환한다', () async {
      when(
        () => mockStoreDataSource.updateStore(
          any(),
          any(),
          isUnchanged: any(named: 'isUnchanged'),
        ),
      ).thenThrow(Exception('Firestore 오류'));

      final result = await repository.updateStore(
        original: fakeStore,
        store: fakeStore,
      );

      expectLeft(result);
    });
  });
}
