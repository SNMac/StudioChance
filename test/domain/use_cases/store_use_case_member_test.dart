import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store_membership.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';

import '../../helpers/either_expectations.dart';
import '../../helpers/fake_entities.dart';
import '../../helpers/mocks.dart';

/// 점포 관리자 1명 규칙(ADR-0004)과 멤버 구성 변경(위임·나가기·신청 취소)
void main() {
  late StoreUseCaseImpl useCase;
  late MockStoreRepository mockStoreRepo;
  late MockUserRepository mockUserRepo;

  const membership = StoreMembership(
    roleByUid: {'admin-1': UserRole.admin, 'staff-1': UserRole.staff},
  );

  setUpAll(() {
    registerFallbackValue(StoreColor.red);
    registerFallbackValue(UserRole.staff);
  });

  setUp(() {
    mockStoreRepo = MockStoreRepository();
    mockUserRepo = MockUserRepository();
    useCase = StoreUseCaseImpl(
      storeRepository: mockStoreRepo,
      userRepository: mockUserRepo,
      serverClockRepository: MockServerClockRepository(),
    );
    when(() => mockStoreRepo.getMembership(any()))
        .thenAnswer((_) async => right(membership));
    when(
      () => mockStoreRepo.removeMember(
        storeId: any(named: 'storeId'),
        uid: any(named: 'uid'),
      ),
    ).thenAnswer((_) async => right(null));
    when(
      () => mockStoreRepo.updateMemberRole(
        storeId: any(named: 'storeId'),
        uid: any(named: 'uid'),
        newRole: any(named: 'newRole'),
      ),
    ).thenAnswer((_) async => right(null));
  });

  group('관리자 역할은 위임으로만 바뀐다', () {
    test('ADMIN 역할 가입 신청은 거부되고 Repository를 호출하지 않는다', () async {
      final result = await useCase.joinStore(
        storeId: 'store-123',
        storeAlias: '별명',
        role: UserRole.admin,
        color: StoreColor.red,
        memo: '',
      );

      expect(expectLeft(result), isA<StoreAdminRoleChangeException>());
      verifyNever(
        () => mockStoreRepo.requestJoinStore(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
          role: any(named: 'role'),
          color: any(named: 'color'),
          storeAlias: any(named: 'storeAlias'),
          memo: any(named: 'memo'),
        ),
      );
    });

    test('ADMIN 역할 승인은 거부된다', () async {
      final result = await useCase.approveMember(
        storeId: 'store-123',
        targetUid: 'pending-1',
        role: UserRole.admin,
      );

      expect(expectLeft(result), isA<StoreAdminRoleChangeException>());
      verifyNever(
        () => mockStoreRepo.approveMember(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
          role: any(named: 'role'),
        ),
      );
    });

    test('다른 멤버를 관리자로 올리면 거부된다', () async {
      final result = await useCase.updateMemberRole(
        storeId: 'store-123',
        targetUid: 'staff-1',
        newRole: UserRole.admin,
      );

      expect(expectLeft(result), isA<StoreAdminRoleChangeException>());
    });

    test('관리자의 역할을 바꾸면 거부된다', () async {
      final result = await useCase.updateMemberRole(
        storeId: 'store-123',
        targetUid: 'admin-1',
        newRole: UserRole.staff,
      );

      expect(expectLeft(result), isA<StoreAdminRoleChangeException>());
      verifyNever(
        () => mockStoreRepo.updateMemberRole(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
          newRole: any(named: 'newRole'),
        ),
      );
    });

    test('스태프의 역할은 바꿀 수 있다', () async {
      final result = await useCase.updateMemberRole(
        storeId: 'store-123',
        targetUid: 'staff-1',
        newRole: UserRole.viewer,
      );

      expectRight(result);
      verify(
        () => mockStoreRepo.updateMemberRole(
          storeId: 'store-123',
          uid: 'staff-1',
          newRole: UserRole.viewer,
        ),
      ).called(1);
    });

    test('관리자는 추방할 수 없다', () async {
      final result = await useCase.removeMember(
        storeId: 'store-123',
        targetUid: 'admin-1',
      );

      expect(expectLeft(result), isA<StoreAdminRoleChangeException>());
      verifyNever(
        () => mockStoreRepo.removeMember(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
        ),
      );
    });

    test('스태프는 추방할 수 있다', () async {
      final result = await useCase.removeMember(
        storeId: 'store-123',
        targetUid: 'staff-1',
      );

      expectRight(result);
      verify(
        () => mockStoreRepo.removeMember(storeId: 'store-123', uid: 'staff-1'),
      ).called(1);
    });
  });

  group('delegateAdmin', () {
    setUp(() {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockStoreRepo.delegateAdmin(
          storeId: any(named: 'storeId'),
          fromUid: any(named: 'fromUid'),
          toUid: any(named: 'toUid'),
          previousAdminRole: any(named: 'previousAdminRole'),
        ),
      ).thenAnswer((_) async => right(null));
    });

    test('나를 이전 관리자, 대상을 새 관리자로 Repository에 넘긴다', () async {
      final result = await useCase.delegateAdmin(
        storeId: 'store-123',
        targetUid: 'staff-1',
        previousAdminRole: UserRole.viewer,
      );

      expectRight(result);
      verify(
        () => mockStoreRepo.delegateAdmin(
          storeId: 'store-123',
          fromUid: fakeUser.id,
          toUid: 'staff-1',
          previousAdminRole: UserRole.viewer,
        ),
      ).called(1);
    });

    test('이전 관리자가 다시 관리자 역할을 받으려 하면 거부된다', () async {
      final result = await useCase.delegateAdmin(
        storeId: 'store-123',
        targetUid: 'staff-1',
        previousAdminRole: UserRole.admin,
      );

      expect(expectLeft(result), isA<StoreValidationException>());
    });

    test('자기 자신에게는 위임할 수 없다', () async {
      final result = await useCase.delegateAdmin(
        storeId: 'store-123',
        targetUid: fakeUser.id,
        previousAdminRole: UserRole.staff,
      );

      expect(expectLeft(result), isA<StoreDelegationTargetInvalidException>());
      verifyNever(
        () => mockStoreRepo.delegateAdmin(
          storeId: any(named: 'storeId'),
          fromUid: any(named: 'fromUid'),
          toUid: any(named: 'toUid'),
          previousAdminRole: any(named: 'previousAdminRole'),
        ),
      );
    });
  });

  group('leaveStore', () {
    test('스태프는 본인 uid로 멤버 제거를 요청한다', () async {
      final staffUser = fakeUser.copyWith(
        storeInfos: [fakeUser.storeInfos.first.copyWith(role: UserRole.staff)],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(staffUser));

      final result = await useCase.leaveStore('store-123');

      expectRight(result);
      verify(
        () =>
            mockStoreRepo.removeMember(storeId: 'store-123', uid: staffUser.id),
      ).called(1);
    });

    test('관리자는 나갈 수 없고 위임·삭제 안내용 점포 정보를 담아 실패한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.leaveStore('store-123');

      final error = expectLeft(result);
      expect(error, isA<StoreAdminHandoverRequiredException>());
      expect((error as StoreAdminHandoverRequiredException).stores, [
        (id: 'store-123', name: '테스트 점포'),
      ]);
      verifyNever(
        () => mockStoreRepo.removeMember(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
        ),
      );
    });
  });

  group('cancelJoinRequest', () {
    test('승인 대기 중인 점포면 본인 uid로 멤버 제거를 요청한다', () async {
      final applicant = fakeUser.copyWith(
        storeInfos: [fakeUser.storeInfos.first.copyWith(isPending: true)],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(applicant));

      final result = await useCase.cancelJoinRequest('store-123');

      expectRight(result);
      verify(
        () =>
            mockStoreRepo.removeMember(storeId: 'store-123', uid: applicant.id),
      ).called(1);
    });

    test('이미 멤버인 점포는 신청 취소할 수 없다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.cancelJoinRequest('store-123');

      expect(expectLeft(result), isA<StoreValidationException>());
      verifyNever(
        () => mockStoreRepo.removeMember(
          storeId: any(named: 'storeId'),
          uid: any(named: 'uid'),
        ),
      );
    });
  });
}
