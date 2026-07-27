import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/fake_entities.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockStoreUseCase extends Mock implements StoreUseCase {}

class FakeAuthInfo extends Fake implements AuthInfo {}

class FakeUser extends Fake implements User {}

void main() {
  late AuthUseCaseImpl useCase;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;
  late MockStoreUseCase mockStoreUseCase;

  setUpAll(() {
    registerFallbackValue(FakeAuthInfo());
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    mockStoreUseCase = MockStoreUseCase();
    useCase = AuthUseCaseImpl(
      authRepository: mockAuthRepo,
      userRepository: mockUserRepo,
      storeUseCase: mockStoreUseCase,
    );
  });

  // =========================================================================
  // fetchOrCreateUser
  // =========================================================================

  group('fetchOrCreateUser', () {
    test('Repository.fetchOrCreateUser를 위임하고 User를 반환한다', () async {
      when(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo))
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.fetchOrCreateUser(fakeAuthInfo);

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Repository 실패를 그대로 전파한다', () async {
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.fetchOrCreateUser(fakeAuthInfo);

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // signInWithGoogle
  // =========================================================================

  group('signInWithGoogle', () {
    test('Auth 성공 시 fetchOrCreateUser를 호출하고 User를 반환한다', () async {
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo))
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.signInWithGoogle();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Auth 실패 시 left를 반환하고 UserRepository를 호출하지 않는다', () async {
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => left(Exception('구글 로그인 실패')));

      final result = await useCase.signInWithGoogle();

      expect(result.isLeft(), true);
      verifyNever(() => mockUserRepo.fetchOrCreateUser(any()));
    });

    test('UserRepository 실패 시 left를 전파한다', () async {
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.signInWithGoogle();

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // signInWithApple
  // =========================================================================

  group('signInWithApple', () {
    test('Auth 성공 시 fetchOrCreateUser를 호출하고 User를 반환한다', () async {
      when(() => mockAuthRepo.signInWithApple())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo))
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.signInWithApple();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Auth 실패 시 left를 반환하고 UserRepository를 호출하지 않는다', () async {
      when(() => mockAuthRepo.signInWithApple())
          .thenAnswer((_) async => left(Exception('Apple 로그인 실패')));

      final result = await useCase.signInWithApple();

      expect(result.isLeft(), true);
      verifyNever(() => mockUserRepo.fetchOrCreateUser(any()));
    });

    test('UserRepository 실패 시 left를 전파한다', () async {
      when(() => mockAuthRepo.signInWithApple())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.signInWithApple();

      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // signOut
  // =========================================================================

  group('signOut', () {
    test('유저가 있는 경우 FCM 토큰 제거 후 signOut한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.removeCurrentDeviceFcmToken(fakeUser.id))
          .thenAnswer((_) async {});
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      await useCase.signOut();

      verify(
        () => mockUserRepo.removeCurrentDeviceFcmToken(fakeUser.id),
      ).called(1);
      verify(() => mockAuthRepo.signOut()).called(1);
    });

    test('유저가 null인 경우 FCM 토큰 제거 없이 signOut한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      await useCase.signOut();

      verifyNever(() => mockUserRepo.removeCurrentDeviceFcmToken(any()));
      verify(() => mockAuthRepo.signOut()).called(1);
    });

    test('getCurrentUser 실패 시 FCM 토큰 제거 없이 signOut한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 조회 실패')));
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      await useCase.signOut();

      verifyNever(() => mockUserRepo.removeCurrentDeviceFcmToken(any()));
      verify(() => mockAuthRepo.signOut()).called(1);
    });

    test('FCM 토큰 제거가 실패해도 signOut을 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.removeCurrentDeviceFcmToken(any()))
          .thenThrow(Exception('FCM 토큰 제거 실패'));
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async {});

      await expectLater(useCase.signOut(), completes);

      verify(() => mockAuthRepo.signOut()).called(1);
    });
  });

  // =========================================================================
  // delete
  // =========================================================================

  group('delete', () {
    test('유저 삭제 성공 + 관리자 점포 삭제 성공 시 AuthRepository.delete를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.softDeleteStore('store-123'))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.delete()).thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isRight(), true);
      verify(() => mockStoreUseCase.softDeleteStore('store-123')).called(1);
      verify(() => mockAuthRepo.delete()).called(1);
    });

    test('현재 유저가 null이면 AuthUserNotFoundException을 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockUserRepo.softDeleteUser(any()));
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('getCurrentUser 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('조회 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
    });

    test('softDeleteUser 실패 시 left를 반환하고 점포 삭제/AuthRepository.delete를 호출하지 않는다',
        () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => left(Exception('탈퇴 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자 점포 삭제 실패 시 left를 반환하고 AuthRepository.delete를 호출하지 않는다',
        () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.softDeleteStore('store-123'))
          .thenAnswer((_) async => left(Exception('점포 삭제 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자가 아닌 점포는 삭제하지 않는다', () async {
      final staffUser = fakeUser.copyWith(
        storeInfos: [
          fakeUser.storeInfos.first.copyWith(role: UserRole.staff),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(staffUser));
      when(() => mockUserRepo.softDeleteUser(staffUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.delete()).thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isRight(), true);
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
    });
  });
}
