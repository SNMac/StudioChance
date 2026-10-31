import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/user.dart';

import '../../helpers/fake_entities.dart';
import 'my_page_test_harness.dart';

const _location = '/my-page/store/store-123';

User _userWithRole(UserRole role, {DateTime? deletedAt}) => fakeUser.copyWith(
  storeInfos: [
    fakeUser.storeInfos.first.copyWith(role: role, deletedAt: deletedAt),
  ],
);

final _staff = fakeUser.copyWith(id: 'staff-1', nickname: '김스태프');
final _admin = fakeUser.copyWith(id: 'admin-1', nickname: '이관리');

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.staff);
    registerFallbackValue(StoreColor.red);
  });

  /// 나(관리자) + 김스태프
  final adminStore = fakeStore.copyWith(
    memberInfos: [
      StoreMemberInfo(user: fakeUser, role: UserRole.admin),
      StoreMemberInfo(user: _staff, role: UserRole.staff),
    ],
  );

  /// 이관리(관리자) + 나(스태프)
  final staffStore = fakeStore.copyWith(
    memberInfos: [
      StoreMemberInfo(user: _admin, role: UserRole.admin),
      StoreMemberInfo(user: fakeUser, role: UserRole.staff),
    ],
  );

  Future<MyPageHarness> pumpDetail(
    WidgetTester tester, {
    required UserRole myRole,
    DateTime? deletedAt,
  }) async {
    final harness = MyPageHarness(
      user: _userWithRole(myRole, deletedAt: deletedAt),
      initialLocation: _location,
    );
    when(() => harness.storeUseCase.getStore(any())).thenAnswer(
      (_) async => right(myRole == UserRole.admin ? adminStore : staffStore),
    );

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    return harness;
  }

  group('역할별 구성', () {
    testWidgets('관리자는 점포 관리 항목과 관리자 위임·점포 삭제를 보고, 나가기는 없다', (tester) async {
      await pumpDetail(tester, myRole: UserRole.admin);

      expect(find.text('점포 정보 수정'), findsOneWidget);
      expect(find.text('승인 대기'), findsOneWidget);
      expect(find.text('관리자 위임'), findsOneWidget);
      expect(find.text('점포 삭제'), findsOneWidget);
      expect(find.text('점포 나가기'), findsNothing);
    });

    testWidgets('다른 멤버가 없으면 관리자 위임을 보여주지 않는다', (tester) async {
      final harness = MyPageHarness(user: fakeUser, initialLocation: _location);
      when(() => harness.storeUseCase.getStore(any())).thenAnswer(
        (_) async => right(
          fakeStore.copyWith(
            memberInfos: [
              StoreMemberInfo(user: fakeUser, role: UserRole.admin),
            ],
          ),
        ),
      );

      await tester.pumpWidget(harness.build());
      await tester.pumpAndSettle();

      expect(find.text('관리자 위임'), findsNothing);
      expect(find.text('점포 삭제'), findsOneWidget);
    });

    testWidgets('스태프는 점포 나가기만 보고, 멤버 행을 탭해도 아무 동작도 하지 않는다', (tester) async {
      await pumpDetail(tester, myRole: UserRole.staff);

      expect(find.text('점포 나가기'), findsOneWidget);
      expect(find.text('점포 정보 수정'), findsNothing);
      expect(find.text('점포 삭제'), findsNothing);

      await tester.tap(find.text('이관리'));
      await tester.pumpAndSettle();

      expect(find.text('추방'), findsNothing);
    });
  });

  group('멤버 관리 (관리자)', () {
    testWidgets('스태프 행을 탭해 뷰어로 바꾸면 확인 없이 바로 적용한다', (tester) async {
      final harness = await pumpDetail(tester, myRole: UserRole.admin);
      when(
        () => harness.storeUseCase.updateMemberRole(
          storeId: any(named: 'storeId'),
          targetUid: any(named: 'targetUid'),
          newRole: any(named: 'newRole'),
        ),
      ).thenAnswer((_) async => right(null));

      await tester.tap(find.text('김스태프'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('뷰어로 변경'));
      await tester.pumpAndSettle();

      verify(
        () => harness.storeUseCase.updateMemberRole(
          storeId: 'store-123',
          targetUid: 'staff-1',
          newRole: UserRole.viewer,
        ),
      ).called(1);
    });

    testWidgets('추방은 확인을 받은 뒤에 한다', (tester) async {
      final harness = await pumpDetail(tester, myRole: UserRole.admin);
      when(
        () => harness.storeUseCase.removeMember(
          storeId: any(named: 'storeId'),
          targetUid: any(named: 'targetUid'),
        ),
      ).thenAnswer((_) async => right(null));

      await tester.tap(find.text('김스태프'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('추방'));
      await tester.pumpAndSettle();

      verifyNever(
        () => harness.storeUseCase.removeMember(
          storeId: any(named: 'storeId'),
          targetUid: any(named: 'targetUid'),
        ),
      );

      // 다이얼로그의 확인 버튼도 '추방'이다
      await tester.tap(find.text('추방').last);
      await tester.pumpAndSettle();

      verify(
        () => harness.storeUseCase.removeMember(
          storeId: 'store-123',
          targetUid: 'staff-1',
        ),
      ).called(1);
    });

    testWidgets('내 행은 탭할 수 없다', (tester) async {
      await pumpDetail(tester, myRole: UserRole.admin);

      await tester.tap(find.text('닉네임 (나)'));
      await tester.pumpAndSettle();

      expect(find.text('추방'), findsNothing);
    });
  });

  testWidgets('관리자 위임: 대상 → 내 역할 → 확인을 거쳐 위임하고 상세 화면으로 돌아간다', (tester) async {
    final harness = await pumpDetail(tester, myRole: UserRole.admin);
    when(
      () => harness.storeUseCase.delegateAdmin(
        storeId: any(named: 'storeId'),
        targetUid: any(named: 'targetUid'),
        previousAdminRole: any(named: 'previousAdminRole'),
      ),
    ).thenAnswer((_) async => right(null));

    await tester.tap(find.text('관리자 위임'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('김스태프'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('뷰어'));
    await tester.pumpAndSettle();

    // 위임 후 내 역할은 사용자 정보를 다시 읽으면 바뀐다
    harness.user = _userWithRole(UserRole.viewer);
    await tester.tap(find.text('위임'));
    await tester.pumpAndSettle();

    verify(
      () => harness.storeUseCase.delegateAdmin(
        storeId: 'store-123',
        targetUid: 'staff-1',
        previousAdminRole: UserRole.viewer,
      ),
    ).called(1);
    // 상세 화면으로 돌아와 뷰어 기준으로 다시 그린다
    expect(find.text('점포 나가기'), findsOneWidget);
    expect(find.text('점포 삭제'), findsNothing);
  });

  testWidgets('점포 나가기에 성공하면 마이페이지로 돌아간다', (tester) async {
    final harness = await pumpDetail(tester, myRole: UserRole.staff);
    when(() => harness.storeUseCase.leaveStore(any()))
        .thenAnswer((_) async => right(null));

    await tester.tap(find.text('점포 나가기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();

    verify(() => harness.storeUseCase.leaveStore('store-123')).called(1);
    expect(find.text('마이페이지'), findsWidgets);
  });

  testWidgets('점포를 삭제하면 마이페이지로 돌아가고, 행에 남은 기간이 보인다', (tester) async {
    final harness = await pumpDetail(tester, myRole: UserRole.admin);
    when(() => harness.storeUseCase.softDeleteStore(any()))
        .thenAnswer((_) async => right(null));
    // 삭제하면 사용자 정보를 다시 읽는다
    harness.user = _userWithRole(UserRole.admin, deletedAt: DateTime.now());

    // 테스트 화면 높이에서는 맨 아래 버튼이 화면 밖에 있을 수 있다
    await tester.ensureVisible(find.text('점포 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('점포 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    verify(() => harness.storeUseCase.softDeleteStore('store-123')).called(1);
    expect(find.text('7일 후 삭제'), findsOneWidget);
    expect(find.text('점포 복구'), findsNothing);
  });

  group('삭제 예정 점포', () {
    testWidgets('관리자는 점포 복구·영구 삭제만 보고 점포 관리 항목은 숨긴다', (tester) async {
      await pumpDetail(
        tester,
        myRole: UserRole.admin,
        deletedAt: DateTime.now(),
      );

      expect(find.text('점포 복구'), findsOneWidget);
      expect(find.text('영구 삭제'), findsOneWidget);
      expect(find.text('점포 정보 수정'), findsNothing);
      expect(find.text('승인 대기'), findsNothing);
      expect(find.text('관리자 위임'), findsNothing);
      expect(find.text('점포 삭제'), findsNothing);
    });

    testWidgets('관리자도 멤버 행을 탭해 역할을 바꾸거나 추방하지 못한다', (tester) async {
      await pumpDetail(
        tester,
        myRole: UserRole.admin,
        deletedAt: DateTime.now(),
      );

      await tester.tap(find.text('김스태프'));
      await tester.pumpAndSettle();

      expect(find.text('추방'), findsNothing);
    });

    testWidgets('스태프는 점포 나가기를 계속 할 수 있다', (tester) async {
      await pumpDetail(
        tester,
        myRole: UserRole.staff,
        deletedAt: DateTime.now(),
      );

      expect(find.text('점포 나가기'), findsOneWidget);
      expect(find.text('점포 복구'), findsNothing);
    });

    testWidgets('점포 복구는 확인 없이 바로 하고 원래 관리자 화면으로 다시 그린다', (tester) async {
      final harness = await pumpDetail(
        tester,
        myRole: UserRole.admin,
        deletedAt: DateTime.now(),
      );
      when(() => harness.storeUseCase.restoreStore(any()))
          .thenAnswer((_) async => right(null));
      harness.user = _userWithRole(UserRole.admin);

      await tester.tap(find.text('점포 복구'));
      await tester.pumpAndSettle();

      verify(() => harness.storeUseCase.restoreStore('store-123')).called(1);
      expect(find.text('점포 정보 수정'), findsOneWidget);
    });

    testWidgets('영구 삭제는 확인을 거치고, 성공하면 마이페이지로 돌아간다', (tester) async {
      final harness = await pumpDetail(
        tester,
        myRole: UserRole.admin,
        deletedAt: DateTime.now(),
      );
      when(() => harness.storeUseCase.permanentlyDeleteStore(any()))
          .thenAnswer((_) async => right(null));

      await tester.tap(find.text('영구 삭제'));
      await tester.pumpAndSettle();
      verifyNever(() => harness.storeUseCase.permanentlyDeleteStore(any()));
      // 다이얼로그의 확인 버튼 (화면의 같은 이름 버튼과 구분해 마지막 것을 누른다)
      await tester.tap(find.text('영구 삭제').last);
      await tester.pumpAndSettle();

      verify(() => harness.storeUseCase.permanentlyDeleteStore('store-123'))
          .called(1);
      expect(find.text('마이페이지'), findsWidgets);
    });
  });

  testWidgets('점포 삭제가 실패하면 상세 화면에 머물고 오류를 알린다', (tester) async {
    final harness = await pumpDetail(tester, myRole: UserRole.admin);
    when(
      () => harness.storeUseCase.softDeleteStore(any()),
    ).thenAnswer((_) async => left(StoreNetworkException(message: '네트워크 오류')));

    // 테스트 화면 높이에서는 맨 아래 버튼이 화면 밖에 있을 수 있다
    await tester.ensureVisible(find.text('점포 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('점포 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    verify(() => harness.storeUseCase.softDeleteStore('store-123')).called(1);
    expect(find.text('점포 정보 수정'), findsOneWidget);
    // 실패는 뒤에 깔린 마이페이지가 알린다 (AlertDialog.adaptive라 타입 대신 제목으로 확인)
    expect(find.text('네트워크 에러가 발생했습니다'), findsOneWidget);
  });

  group('내 설정', () {
    testWidgets('점포 색상을 고르면 저장하고 바로 상세 화면으로 돌아간다', (tester) async {
      final harness = await pumpDetail(tester, myRole: UserRole.staff);
      when(
        () => harness.userUseCase.updateStoreInfo(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          color: any(named: 'color'),
        ),
      ).thenAnswer((_) async => right(null));

      await tester.tap(find.text('점포 색상'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('파란색'));
      await tester.pumpAndSettle();

      verify(
        () => harness.userUseCase.updateStoreInfo(
          uid: 'user-123',
          storeId: 'store-123',
          color: StoreColor.blue,
        ),
      ).called(1);
      expect(find.text('점포 나가기'), findsOneWidget);
    });

    testWidgets('점포 메모는 완료를 눌러야 저장한다', (tester) async {
      final harness = await pumpDetail(tester, myRole: UserRole.staff);
      when(
        () => harness.userUseCase.updateStoreInfo(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          memo: any(named: 'memo'),
        ),
      ).thenAnswer((_) async => right(null));

      await tester.tap(find.text('점포 메모'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '주차 2대');
      await tester.pump();

      verifyNever(
        () => harness.userUseCase.updateStoreInfo(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          memo: any(named: 'memo'),
        ),
      );

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      verify(
        () => harness.userUseCase.updateStoreInfo(
          uid: 'user-123',
          storeId: 'store-123',
          memo: '주차 2대',
        ),
      ).called(1);
      expect(find.text('점포 나가기'), findsOneWidget);
    });

    testWidgets('삭제 예정 점포에서도 점포 별명을 고칠 수 있다', (tester) async {
      final harness = await pumpDetail(
        tester,
        myRole: UserRole.staff,
        deletedAt: DateTime.now(),
      );
      when(
        () => harness.userUseCase.updateStoreAlias(
          uid: any(named: 'uid'),
          storeId: any(named: 'storeId'),
          alias: any(named: 'alias'),
        ),
      ).thenAnswer((_) async => right(null));

      await tester.tap(find.text('점포 별명'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '본점');
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      verify(
        () => harness.userUseCase.updateStoreAlias(
          uid: 'user-123',
          storeId: 'store-123',
          alias: '본점',
        ),
      ).called(1);
      expect(find.text('점포 나가기'), findsOneWidget);
    });
  });

  testWidgets('점포 정보 수정은 새로 조회한 점포로 수정 화면을 연다', (tester) async {
    final harness = await pumpDetail(tester, myRole: UserRole.admin);
    // 상세 화면 캐시와 다른 최신 값 — 진입할 때 새로 조회했는지 구분한다
    when(() => harness.storeUseCase.getStoreForEdit(any()))
        .thenAnswer((_) async => right(adminStore.copyWith(address: '최신 주소')));

    await tester.tap(find.text('점포 정보 수정'));
    await tester.pumpAndSettle();

    expect(find.text('수정 화면: 최신 주소'), findsOneWidget);
  });
}
