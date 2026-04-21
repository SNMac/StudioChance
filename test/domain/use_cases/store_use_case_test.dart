import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/store_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/fake_entities.dart';

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

  // =========================================================================
  // createStore
  // =========================================================================

  group('createStore', () {
    test('현재 유저를 Admin으로 추가하여 Repository.createStore를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      Store? capturedStore;
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((invocation) async {
        capturedStore =
            invocation.namedArguments[#store] as Store;
        return right(capturedStore!);
      });

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '새 점포 메모',
      );

      expect(result.isRight(), true);
      expect(capturedStore?.memberInfos.length, 1);
      expect(capturedStore?.memberInfos.first.user.id, fakeUser.id);
      expect(capturedStore?.memberInfos.first.role, UserRole.admin);
      expect(capturedStore?.waitingMemberInfos, isEmpty);
    });

    test('createStore 호출 시 color와 memo가 그대로 전달된다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(fakeStore));

      await useCase.createStore(
        store: fakeStore,
        color: StoreColor.green,
        memo: '메모 내용',
      );

      verify(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: StoreColor.green,
          memo: '메모 내용',
        ),
      ).called(1);
    });

    test('유저 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
      verifyNever(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.createStore(
          store: any(named: 'store'),
          color: any(named: 'color'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => left(Exception('점포 생성 실패')));

      final result = await useCase.createStore(
        store: fakeStore,
        color: StoreColor.blue,
        memo: '메모',
      );

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // getStoreByInviteCode
  // =========================================================================

  group('getStoreByInviteCode', () {
    test('유효한 초대 코드로 점포를 반환한다', () async {
      when(() => mockStoreRepo.getStoreByInviteCode('VALID1'))
          .thenAnswer((_) async => right(fakeStore));

      final result = await useCase.getStoreByInviteCode('VALID1');

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), fakeStore);
    });

    test('점포가 없으면 right(null)을 반환한다', () async {
      when(() => mockStoreRepo.getStoreByInviteCode(any()))
          .thenAnswer((_) async => right(null));

      final result = await useCase.getStoreByInviteCode('NOTFND');

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), isNull);
    });

    test('Repository 실패 시 left를 반환한다', () async {
      when(() => mockStoreRepo.getStoreByInviteCode(any()))
          .thenAnswer((_) async => left(Exception('초대 코드 오류')));

      final result = await useCase.getStoreByInviteCode('INVALD');

      expect(result.isLeft(), true);
    });
  });
}
