import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/either_expectations.dart';
import '../../helpers/mocks.dart';

void main() {
  late AuthUseCaseImpl useCase;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;
  late MockStoreUseCase mockStoreUseCase;

  setUpAll(() {
    registerFallbackValue(FakeAuthInfo());
    registerFallbackValue(fakeUser);
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

      expectRight(result);
      expect(expectRight(result), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
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

      expectRight(result);
      expect(expectRight(result), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Auth 실패 시 left를 반환하고 UserRepository를 호출하지 않는다', () async {
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => left(Exception('구글 로그인 실패')));

      final result = await useCase.signInWithGoogle();

      expectLeft(result);
      verifyNever(() => mockUserRepo.fetchOrCreateUser(any()));
    });

    test('UserRepository 실패 시 left를 전파한다', () async {
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.signInWithGoogle();

      expectLeft(result);
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

      expectRight(result);
      expect(expectRight(result), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Auth 실패 시 left를 반환하고 UserRepository를 호출하지 않는다', () async {
      when(() => mockAuthRepo.signInWithApple())
          .thenAnswer((_) async => left(Exception('Apple 로그인 실패')));

      final result = await useCase.signInWithApple();

      expectLeft(result);
      verifyNever(() => mockUserRepo.fetchOrCreateUser(any()));
    });

    test('UserRepository 실패 시 left를 전파한다', () async {
      when(() => mockAuthRepo.signInWithApple())
          .thenAnswer((_) async => right(fakeAuthInfo));
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.signInWithApple();

      expectLeft(result);
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

      verify(() => mockUserRepo.removeCurrentDeviceFcmToken(fakeUser.id))
          .called(1);
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
    // 스태프로 속한 점포 하나와 승인 대기 점포 하나를 더 가진 사용자
    final memberUser = fakeUser.copyWith(
      storeInfos: [
        ...fakeUser.storeInfos,
        fakeUser.storeInfos.first.copyWith(
          id: 'store-staff',
          role: UserRole.staff,
        ),
        fakeUser.storeInfos.first.copyWith(
          id: 'store-pending',
          role: UserRole.staff,
          isPending: true,
        ),
      ],
    );

    void verifyNothingWritten() {
      verifyNever(() => mockStoreUseCase.leaveStore(any()));
      verifyNever(() => mockStoreUseCase.cancelJoinRequest(any()));
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
      verifyNever(() => mockUserRepo.markAccountDeleted(any()));
      verifyNever(() => mockAuthRepo.delete());
    }

    setUp(() {
      // 기본값: 관리자 점포가 혼자 쓰는 점포라 계정 삭제가 막히지 않고, 모든 단계가 성공한다
      when(() => mockStoreUseCase.getMembership(any())).thenAnswer(
        (_) async =>
            right(StoreMembership(roleByUid: {fakeUser.id: UserRole.admin})),
      );
      when(() => mockAuthRepo.prepareDeletion())
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.leaveStore(any()))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.cancelJoinRequest(any()))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.softDeleteStore(any()))
          .thenAnswer((_) async => right(null));
      when(() => mockUserRepo.markAccountDeleted(any()))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.delete()).thenAnswer((_) async => right(null));
    });

    test('다른 멤버가 있는 관리자 점포가 있으면 재인증도 하지 않고 막힌 점포 목록과 함께 실패한다', () async {
      final user = fakeUser.copyWith(
        storeInfos: [
          ...fakeUser.storeInfos,
          fakeUser.storeInfos.first.copyWith(id: 'store-solo', name: '혼자 점포'),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(user));
      when(() => mockStoreUseCase.getMembership('store-123')).thenAnswer(
        (_) async => right(
          StoreMembership(
            roleByUid: {user.id: UserRole.admin, 'staff-1': UserRole.staff},
          ),
        ),
      );

      final result = await useCase.delete();

      final error = expectLeft(result);
      expect(error, isA<StoreAdminHandoverRequiredException>());
      expect((error as StoreAdminHandoverRequiredException).stores, [
        (id: 'store-123', name: '테스트 점포'),
      ]);
      verifyNever(() => mockAuthRepo.prepareDeletion());
      verifyNothingWritten();
    });

    test('관리자 점포 조회가 실패하면 아무것도 쓰지 않고 실패한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockStoreUseCase.getMembership('store-123'))
          .thenAnswer((_) async => left(Exception('조회 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNothingWritten();
    });

    test('재인증·Apple revoke가 중단되면 아무것도 쓰지 않고 실패한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));
      when(() => mockAuthRepo.prepareDeletion())
          .thenAnswer((_) async => left(Exception('재인증 취소')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNothingWritten();
    });

    test('점포 정리 → 사용자 문서 → Auth 순서로 지운다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));

      final result = await useCase.delete();

      expectRight(result);
      verifyInOrder([
        () => mockAuthRepo.prepareDeletion(),
        () => mockStoreUseCase.leaveStore('store-staff'),
        () => mockStoreUseCase.cancelJoinRequest('store-pending'),
        () => mockStoreUseCase.softDeleteStore('store-123'),
        () => mockUserRepo.markAccountDeleted(memberUser),
        () => mockAuthRepo.delete(),
      ]);
    });

    test('관리자 점포는 나가지 않고, 멤버·승인 대기 점포는 삭제하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));

      await useCase.delete();

      verifyNever(() => mockStoreUseCase.leaveStore('store-123'));
      verifyNever(() => mockStoreUseCase.leaveStore('store-pending'));
      verifyNever(() => mockStoreUseCase.softDeleteStore('store-staff'));
      verifyNever(() => mockStoreUseCase.softDeleteStore('store-pending'));
    });

    // 승인 전에는 멤버가 아니라 Rules가 점포 수정을 거부해 계정 삭제가 실패한다
    test('승인 대기 중인 점포는 관리자 역할로 신청했어도 삭제하지 않고 신청을 취소한다', () async {
      final applicant = fakeUser.copyWith(
        storeInfos: [
          ...fakeUser.storeInfos,
          fakeUser.storeInfos.first.copyWith(
            id: 'store-pending',
            isPending: true,
          ),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(applicant));

      final result = await useCase.delete();

      expectRight(result);
      verify(() => mockStoreUseCase.cancelJoinRequest('store-pending'))
          .called(1);
      verifyNever(() => mockStoreUseCase.softDeleteStore('store-pending'));
    });

    test('점포 나가기가 실패하면 사용자 문서와 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));
      when(() => mockStoreUseCase.leaveStore('store-staff'))
          .thenAnswer((_) async => left(Exception('나가기 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(() => mockUserRepo.markAccountDeleted(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자 점포 삭제가 실패하면 사용자 문서와 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockStoreUseCase.softDeleteStore('store-123'))
          .thenAnswer((_) async => left(Exception('점포 삭제 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(() => mockUserRepo.markAccountDeleted(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('사용자 문서 정리가 실패하면 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.markAccountDeleted(any()))
          .thenAnswer((_) async => left(Exception('문서 정리 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(() => mockAuthRepo.delete());
    });

    test('현재 유저가 null이면 AuthUserNotFoundException을 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(expectLeft(result), isA<AuthUserNotFoundException>());
      verifyNever(() => mockAuthRepo.prepareDeletion());
      verifyNothingWritten();
    });

    test('getCurrentUser 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('조회 실패')));

      final result = await useCase.delete();

      expectLeft(result);
    });
  });
}
