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
  // findStoresBlockingDeletion
  // =========================================================================

  group('findStoresBlockingDeletion', () {
    StoreMembership withStaff(String adminUid) => StoreMembership(
      roleByUid: {adminUid: UserRole.admin, 'staff-1': UserRole.staff},
    );

    test('다른 멤버가 있는 관리자 점포만 돌려주고 아무것도 쓰지 않는다', () async {
      final user = fakeUser.copyWith(
        storeInfos: [
          ...fakeUser.storeInfos,
          fakeUser.storeInfos.first.copyWith(id: 'store-solo', name: '혼자 점포'),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(user));
      when(() => mockStoreUseCase.getMembership('store-123'))
          .thenAnswer((_) async => right(withStaff(user.id)));
      when(() => mockStoreUseCase.getMembership('store-solo')).thenAnswer(
        (_) async =>
            right(StoreMembership(roleByUid: {user.id: UserRole.admin})),
      );

      final result = await useCase.findStoresBlockingDeletion();

      expect(expectRight(result), [(id: 'store-123', name: '테스트 점포')]);
      verifyNever(() => mockAuthRepo.prepareDeletion());
      verifyNever(() => mockAuthRepo.delete());
    });

    test('삭제 예정 점포는 다른 멤버가 있어도 막지 않는다', () async {
      final user = fakeUser.copyWith(
        storeInfos: [
          fakeUser.storeInfos.first.copyWith(deletedAt: DateTime.now()),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(user));
      when(() => mockStoreUseCase.getMembership('store-123'))
          .thenAnswer((_) async => right(withStaff(user.id)));

      final result = await useCase.findStoresBlockingDeletion();

      expect(expectRight(result), isEmpty);
    });

    test('로그인된 사용자가 없으면 실패한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.findStoresBlockingDeletion();

      expect(expectLeft(result), isA<AuthUserNotFoundException>());
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
      verifyNever(() => mockStoreUseCase.permanentlyDeleteStore(any()));
      verifyNever(
        () => mockUserRepo.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      );
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
      when(() => mockStoreUseCase.permanentlyDeleteStore(any()))
          .thenAnswer((_) async => right(null));
      when(
        () => mockUserRepo.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => right(null));
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

    test('다른 멤버가 있어도 삭제 예정 점포는 계정 삭제를 막지 않고 영구 삭제한다', () async {
      // 복구는 관리자만 할 수 있어 관리자가 떠나면 남겨 둘 이유가 없다 (ADR-0007)
      final user = fakeUser.copyWith(
        storeInfos: [
          fakeUser.storeInfos.first.copyWith(deletedAt: DateTime.now()),
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

      expectRight(result);
      verify(() => mockStoreUseCase.permanentlyDeleteStore('store-123'))
          .called(1);
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
        () => mockStoreUseCase.permanentlyDeleteStore('store-123'),
        () => mockUserRepo.markAccountDeleted('user-123', nickname: '닉네임'),
        () => mockAuthRepo.delete(),
      ]);
    });

    test('관리자 점포는 나가지 않고, 멤버·승인 대기 점포는 영구 삭제하지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));

      await useCase.delete();

      verifyNever(() => mockStoreUseCase.leaveStore('store-123'));
      verifyNever(() => mockStoreUseCase.leaveStore('store-pending'));
      verifyNever(() => mockStoreUseCase.permanentlyDeleteStore('store-staff'));
      verifyNever(
        () => mockStoreUseCase.permanentlyDeleteStore('store-pending'),
      );
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
      verifyNever(
        () => mockStoreUseCase.permanentlyDeleteStore('store-pending'),
      );
    });

    test('점포 나가기가 실패하면 사용자 문서와 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(memberUser));
      when(() => mockStoreUseCase.leaveStore('store-staff'))
          .thenAnswer((_) async => left(Exception('나가기 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(
        () => mockUserRepo.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      );
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자 점포 영구 삭제가 실패하면 사용자 문서와 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockStoreUseCase.permanentlyDeleteStore('store-123'))
          .thenAnswer((_) async => left(Exception('점포 삭제 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(
        () => mockUserRepo.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      );
      verifyNever(() => mockAuthRepo.delete());
    });

    test('사용자 문서 정리가 실패하면 Auth 계정을 지우지 않는다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockUserRepo.markAccountDeleted(
          any(),
          nickname: any(named: 'nickname'),
        ),
      ).thenAnswer((_) async => left(Exception('문서 정리 실패')));

      final result = await useCase.delete();

      expectLeft(result);
      verifyNever(() => mockAuthRepo.delete());
    });

    test('닉네임이 없으면 소셜 계정 이름을 남긴다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser.copyWith(nickname: null)));

      await useCase.delete();

      verify(
        () => mockUserRepo.markAccountDeleted('user-123', nickname: '테스트 유저'),
      ).called(1);
    });

    test('남기는 소셜 계정 이름은 닉네임 최대 길이까지만이다', () async {
      when(() => mockUserRepo.getCurrentUser()).thenAnswer(
        (_) async =>
            right(fakeUser.copyWith(nickname: null, name: ' 가나다라마바사아자차카타 ')),
      );

      await useCase.delete();

      verify(
        () =>
            mockUserRepo.markAccountDeleted('user-123', nickname: '가나다라마바사아자차'),
      ).called(1);
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
