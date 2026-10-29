import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form/text_action_button.dart';

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

  const blockingStores = [(id: 'store-123', name: '테스트 점포')];
  final accountDeletionButton = find.widgetWithText(TextActionButton, '계정 삭제');

  testWidgets('계정 삭제는 막는 점포가 없으면 확인 화면을 열고, 그 화면에서 눌러야 삭제한다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right([]));
    when(() => harness.authUseCase.delete())
        .thenAnswer((_) async => right(null));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    verifyNever(() => harness.authUseCase.delete());
    expect(find.text('계정을 삭제할까요?'), findsOneWidget);

    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();

    verify(() => harness.authUseCase.delete()).called(1);
    expect(find.text('오류'), findsNothing);
  });

  testWidgets('계정 삭제가 막히면 막힌 점포를 보여주고, 행을 탭하면 그 점포 상세로 간다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right(blockingStores));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();

    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제하기 전에'), findsOneWidget);
    expect(accountDeletionButton, findsNothing);

    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    expect(find.text('점포 정보 수정'), findsOneWidget);
    verifyNever(() => harness.authUseCase.delete());
  });

  testWidgets('계정 삭제 안내에서 연 점포를 삭제하고 돌아오면 계정 삭제 확인이 된다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));
    when(() => harness.storeUseCase.softDeleteStore(any()))
        .thenAnswer((_) async => right(null));
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right(blockingStores));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
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

    expect(find.text('계정을 삭제할까요?'), findsOneWidget);
    expect(accountDeletionButton, findsOneWidget);
  });

  testWidgets('계정 삭제 안내에서 연 점포의 멤버를 모두 내보내고 돌아오면 다시 확인해 계정 삭제 확인이 된다', (
    tester,
  ) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.storeUseCase.getStore(any()))
        .thenAnswer((_) async => right(fakeStore));
    var checks = 0;
    // 처음엔 막히고, 점포 상세에서 돌아온 뒤에는 막지 않는다 (멤버를 모두 내보냄)
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right(checks++ == 0 ? blockingStores : []));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.text('점포 정보 수정'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제할까요?'), findsOneWidget);
    expect(accountDeletionButton, findsOneWidget);
  });

  testWidgets('한 번 막혔던 뒤 다시 계정 삭제를 진행하는 동안 지난 막힘 안내로 돌아가지 않는다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right([]));
    when(() => harness.authUseCase.delete()).thenAnswer(
      (_) async => left(
        StoreAdminHandoverRequiredException(
          stores: blockingStores,
          message: '다른 멤버가 있는 관리자 점포',
        ),
      ),
    );

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    expect(find.text('계정을 삭제하기 전에'), findsOneWidget);

    // 마이페이지로 돌아가 다시 연다. 그 사이 막던 점포는 정리됐다
    GoRouter.of(tester.element(find.text('계정을 삭제하기 전에'))).pop();
    await tester.pumpAndSettle();
    final deletion = Completer<Either<Exception, void>>();
    when(() => harness.authUseCase.delete()).thenAnswer((_) => deletion.future);
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pump();

    expect(find.text('계정을 삭제할까요?'), findsOneWidget);
    expect(find.text('계정을 삭제하기 전에'), findsNothing);

    deletion.complete(right(null));
    await tester.pumpAndSettle();
  });

  testWidgets('계정 삭제 확인 뒤 그 사이 멤버가 늘어 막히면 오류 대신 막힌 점포를 안내한다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => right([]));
    when(() => harness.authUseCase.delete()).thenAnswer(
      (_) async => left(
        StoreAdminHandoverRequiredException(
          stores: blockingStores,
          message: '다른 멤버가 있는 관리자 점포',
        ),
      ),
    );

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제하기 전에'), findsOneWidget);
    expect(find.text('테스트 점포'), findsOneWidget);
    expect(find.text('오류'), findsNothing);
  });

  testWidgets('막는 점포를 확인하지 못하면 오류를 알리고 계정 삭제 화면을 열지 않는다', (tester) async {
    final harness = MyPageHarness(user: fakeUser);
    when(() => harness.authUseCase.findStoresBlockingDeletion())
        .thenAnswer((_) async => left(Exception('네트워크 오류')));

    await tester.pumpWidget(harness.build());
    await tester.pumpAndSettle();
    await tester.tap(accountDeletionButton);
    await tester.pumpAndSettle();

    expect(find.text('오류'), findsOneWidget);
    expect(find.text('계정을 삭제할까요?'), findsNothing);
    expect(find.text('계정을 삭제하기 전에'), findsNothing);
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
