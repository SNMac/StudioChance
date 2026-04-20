import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/fake_data.dart';

class MockStoreRepository extends Mock implements StoreRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeStore extends Fake implements Store {}

void main() {
  late StoreUseCaseImpl useCase;
  late MockStoreRepository mockStoreRepo;
  late MockUserRepository mockUserRepo;

  setUpAll(() {
    registerFallbackValue(FakeStore());
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreRepo = MockStoreRepository();
    mockUserRepo = MockUserRepository();
    useCase = StoreUseCaseImpl(
      storeRepository: mockStoreRepo,
      userRepository: mockUserRepo,
    );
  });

  group('updateStore', () {
    test('현재 유저와 함께 Repository.updateStore를 올바른 파라미터로 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.updateStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isRight(), true);
      verify(
        () => mockStoreRepo.updateStore(
          store: fakeStore,
          uid: fakeUser.id,
          color: StoreColor.blue,
          memo: '새 메모',
        ),
      ).called(1);
    });

    test('현재 유저 조회 실패 시 left(exception)를 반환한다', () async {
      final exception = Exception('유저 조회 실패');
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(exception));

      final result = await useCase.updateStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isLeft(), true);
      verifyNever(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('현재 유저가 null이면 left(exception)를 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.updateStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isLeft(), true);
    });

    test('Repository 실패 시 left(exception)를 전파한다', () async {
      final exception = Exception('점포 업데이트 실패');
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.updateStore(
          store: any(named: 'store'),
          uid: any(named: 'uid'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => left(exception));

      final result = await useCase.updateStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 메모',
      );

      expect(result.isLeft(), true);
    });
  });
}
