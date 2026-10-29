import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';

import '../../helpers/fake_entities.dart';
import 'my_page_test_harness.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.staff);
  });

  testWidgets('점포 행을 탭하면 그 점포의 상세 화면을 연다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    expect(find.text('점포 정보 수정'), findsOneWidget);
  });

  testWidgets('삭제 예정 점포는 역할 대신 남은 기간을 표시하고, 탭하면 상세 화면을 연다', (tester) async {
    final harness = MyPageHarness(
      user: fakeUser.copyWith(
        storeInfos: [
          fakeUser.storeInfos.first.copyWith(
            deletedAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      ),
    );
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    expect(find.text('3일 후 삭제'), findsOneWidget);
    expect(find.text('관리자'), findsNothing);

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    expect(find.text('점포 복구'), findsOneWidget);
  });

  testWidgets('승인 대기 중인 점포는 역할 대신 승인 대기로 표시하고, 신청을 취소할 수 있다', (tester) async {
    final applicant = fakeUser.copyWith(
      storeInfos: [
        fakeUser.storeInfos.first.copyWith(
          role: UserRole.staff,
          isPending: true,
        ),
      ],
    );
    final harness = MyPageHarness(user: applicant);
    when(() => harness.storeUseCase.cancelJoinRequest(any()))
        .thenAnswer((_) async => right(null));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    expect(find.text('승인 대기'), findsOneWidget);
    expect(find.text(UserRole.staff.displayName), findsNothing);

    await tester.tap(find.text('신청 취소'));
    await tester.pumpAndSettle();
    // 다이얼로그의 확인 버튼도 '신청 취소'다
    await tester.tap(find.text('신청 취소').last);
    await tester.pumpAndSettle();

    verify(() => harness.storeUseCase.cancelJoinRequest('store-123')).called(1);
  });

  testWidgets('승인 대기 점포 행은 탭해도 상세 화면을 열지 않는다', (tester) async {
    final applicant = fakeUser.copyWith(
      storeInfos: [fakeUser.storeInfos.first.copyWith(isPending: true)],
    );
    final harness = MyPageHarness(user: applicant);

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    expect(find.text('점포 정보 수정'), findsNothing);
    verifyNever(() => harness.storeUseCase.getStore(any()));
  });

  testWidgets('계정 삭제는 확인을 받은 뒤에 하고, 성공하면 오류나 안내 화면을 띄우지 않는다', (tester) async {
    // 성공 뒤 로그인 화면으로 가는 것은 인증 상태를 보는 라우터 redirect가 맡는다
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.authUseCase.delete())
        .thenAnswer((_) async => right(null));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    verifyNever(() => harness.authUseCase.delete());

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    verify(() => harness.authUseCase.delete()).called(1);
    expect(find.text('계정을 삭제하기 전에'), findsNothing);
    expect(find.text('오류'), findsNothing);
  });

  testWidgets('계정 삭제가 막히면 막힌 점포를 보여주고, 행을 탭하면 그 점포 상세로 간다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));
    when(() => harness.authUseCase.delete()).thenAnswer(
      (_) async => left(
        StoreAdminHandoverRequiredException(
          stores: [(id: 'store-123', name: '테스트 점포')],
          message: '다른 멤버가 있는 관리자 점포',
        ),
      ),
    );

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제하기 전에'), findsOneWidget);

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    expect(find.text('점포 정보 수정'), findsOneWidget);
  });

  testWidgets('계정 삭제 안내에서 연 점포를 삭제하고 돌아오면, 막힌 점포가 없으므로 다시 시도하라고 알린다', (
    tester,
  ) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));
    when(() => harness.storeUseCase.softDeleteStore(any()))
        .thenAnswer((_) async => right(null));
    when(() => harness.authUseCase.delete()).thenAnswer(
      (_) async => left(
        StoreAdminHandoverRequiredException(
          stores: [(id: 'store-123', name: '테스트 점포')],
          message: '다른 멤버가 있는 관리자 점포',
        ),
      ),
    );

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    // 삭제하면 사용자 정보를 다시 읽고, 그 점포는 삭제 예정 점포가 되어 계정 삭제를 막지 않는다
    harness.user = fakeUser.copyWith(
      storeInfos: [
        fakeUser.storeInfos.first.copyWith(deletedAt: DateTime.now()),
      ],
    );
    await tester.tap(find.text('점포 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    // 삭제 예정 점포로 다시 그려진 상세 화면에 머문다
    expect(find.text('점포 복구'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제하기 전에'), findsOneWidget);
    expect(find.textContaining('이제 계정을 삭제할 수 있습니다'), findsOneWidget);
  });

  testWidgets('점포 상세에서 연 승인 대기 모달의 승인이 실패하면 오류 다이얼로그로 알린다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    final store = fakeStore.copyWith(
      waitingMemberInfos: [
        StoreMemberInfo(
          user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
          role: UserRole.staff,
        ),
      ],
    );
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(store));
    when(
      () => harness.storeUseCase.approveMember(
        storeId: any(named: 'storeId'),
        targetUid: any(named: 'targetUid'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) async => left(Exception('네트워크 오류')));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('승인 대기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('승인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 실패는 뒤에 깔린 마이페이지가 한 번만 알린다. 본문은 insertZwj()로 글자 사이에
    // ZWJ가 들어가 정확히 매칭되지 않으므로 제목만 검증한다
    expect(find.text('오류'), findsOneWidget);
  });
}
