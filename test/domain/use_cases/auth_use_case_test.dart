import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';

import '../../helpers/fake_data.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class FakeAuthInfo extends Fake implements AuthInfo {}

class FakeUser extends Fake implements User {}

void main() {
  late AuthUseCaseImpl useCase;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;

  setUpAll(() {
    registerFallbackValue(FakeAuthInfo());
    registerFallbackValue(FakeUser());
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    useCase = AuthUseCaseImpl(
      authRepository: mockAuthRepo,
      userRepository: mockUserRepo,
    );
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
}
