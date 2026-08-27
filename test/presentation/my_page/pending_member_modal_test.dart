import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/providers/store_detail_provider.dart';
import 'package:studio_chance/presentation/my_page/widgets/pending_member_modal.dart';

import '../../helpers/fake_entities.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

Store storeWithWaiting(List<StoreMemberInfo> waiting) =>
    fakeStore.copyWith(waitingMemberInfos: waiting);

Widget wrap(Widget child, {required Store store}) {
  return ProviderScope(
    overrides: [
      storeDetailProvider(store.id).overrideWith((ref) async => store),
    ],
    child: MaterialApp(
      home: Scaffold(body: LayoutBuilder(builder: (_, constraints) => child)),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.staff);
  });

  testWidgets('대기 중인 신청자의 닉네임과 신청 역할을 보여준다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
        role: UserRole.staff,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('홍길동'), findsOneWidget);
    expect(find.text(UserRole.staff.displayName), findsOneWidget);
  });

  testWidgets('로딩 중에는 "대기 중인 가입 신청이 없습니다" 문구를 보여주지 않는다', (tester) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 완료되지 않는 Future로 AsyncLoading 상태를 고정한다.
          storeDetailProvider(
            store.id,
          ).overrideWith((ref) => Completer<Store?>().future),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (_, constraints) => PendingMemberModal(
                storeId: store.id,
                maxAvailableHeight: 600,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('대기 중인 가입 신청이 없습니다'), findsNothing);
  });

  testWidgets('대기자가 없으면 안내 문구를 보여준다', (tester) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('대기 중인 가입 신청이 없습니다'), findsOneWidget);
  });

  testWidgets('닉네임이 없으면 이름으로 대체 표시한다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-2', nickname: null, name: '김철수'),
        role: UserRole.viewer,
      ),
    ]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('김철수'), findsOneWidget);
  });

  testWidgets('승인 처리 중에는 버튼이 비활성화되어 중복 제출을 막는다', (tester) async {
    final store = storeWithWaiting([
      StoreMemberInfo(
        user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
        role: UserRole.staff,
      ),
    ]);

    final mockStoreUseCase = MockStoreUseCase();
    final completer = Completer<Either<Exception, void>>();
    when(
      () => mockStoreUseCase.approveMember(
        storeId: any(named: 'storeId'),
        targetUid: any(named: 'targetUid'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) => completer.future);

    // showCustomAlertDialog의 확인 버튼은 go_router의 context.pop()을 사용하므로
    // (custom_alert_dialog.dart) 순수 MaterialApp이 아닌 GoRouter 하네스가 필요하다.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: LayoutBuilder(
              builder: (_, constraints) => PendingMemberModal(
                storeId: store.id,
                maxAvailableHeight: 600,
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeDetailProvider(store.id).overrideWith((ref) async => store),
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // 승인 → 확인 다이얼로그 → 확인 (approve() 시작, 아직 완료 안 됨)
    await tester.tap(find.text('승인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 처리 중 다시 탭해도 버튼이 비활성화되어 있어 확인 다이얼로그가 다시 뜨지 않는다
    await tester.tap(find.text('승인'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('확인'), findsNothing);

    completer.complete(left(Exception('테스트 예외')));
    await tester.pumpAndSettle();

    verify(
      () => mockStoreUseCase.approveMember(
        storeId: any(named: 'storeId'),
        targetUid: any(named: 'targetUid'),
        role: any(named: 'role'),
      ),
    ).called(1);
  });

  // =========================================================================
  // 초대 코드 발급
  // =========================================================================

  /// 초대 코드 섹션이 든 모달을 띄운다. 발급은 UseCase를 직접 부르므로
  /// storeUseCaseProvider까지 오버라이드해야 한다.
  Future<Store> pumpWithInviteMock(
    WidgetTester tester,
    MockStoreUseCase mockStoreUseCase,
  ) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeDetailProvider(store.id).overrideWith((ref) async => store),
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (_, constraints) => PendingMemberModal(
                storeId: store.id,
                maxAvailableHeight: 600,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('발급 버튼을 누르면 UseCase를 호출하고 받은 코드를 보여준다', (tester) async {
    final mockStoreUseCase = MockStoreUseCase();
    when(
      () => mockStoreUseCase.createInviteCode(
        any(),
        forceRegenerate: any(named: 'forceRegenerate'),
      ),
    ).thenAnswer((_) async => right(const InviteInfo(inviteCode: 'A7K2P9')));

    final store = await pumpWithInviteMock(tester, mockStoreUseCase);

    // 발급 전에는 코드가 없다 — 만료 여부를 알 수 없어 기존 코드를 미리 띄우지 않는다.
    expect(find.text('A7K2P9'), findsNothing);

    await tester.tap(find.text('발급'));
    await tester.pumpAndSettle();

    expect(find.text('A7K2P9'), findsOneWidget);
    verify(
      () => mockStoreUseCase.createInviteCode(store.id, forceRegenerate: false),
    ).called(1);
  });

  testWidgets('발급 처리 중에는 버튼이 비활성화되어 중복 발급을 막는다', (tester) async {
    final mockStoreUseCase = MockStoreUseCase();
    final completer = Completer<Either<Exception, InviteInfo>>();
    when(
      () => mockStoreUseCase.createInviteCode(
        any(),
        forceRegenerate: any(named: 'forceRegenerate'),
      ),
    ).thenAnswer((_) => completer.future);

    await pumpWithInviteMock(tester, mockStoreUseCase);

    await tester.tap(find.text('발급'));
    await tester.pump();

    // 처리 중 다시 탭해도 호출이 늘지 않는다
    await tester.tap(find.text('발급'), warnIfMissed: false);
    await tester.pump();

    completer.complete(right(const InviteInfo(inviteCode: 'A7K2P9')));
    await tester.pumpAndSettle();

    verify(
      () => mockStoreUseCase.createInviteCode(
        any(),
        forceRegenerate: any(named: 'forceRegenerate'),
      ),
    ).called(1);
  });

  testWidgets('재발급을 확인하면 forceRegenerate로 다시 발급한다', (tester) async {
    final store = storeWithWaiting([]);
    final mockStoreUseCase = MockStoreUseCase();
    when(
      () => mockStoreUseCase.createInviteCode(
        any(),
        forceRegenerate: any(named: 'forceRegenerate'),
      ),
    ).thenAnswer((_) async => right(const InviteInfo(inviteCode: 'A7K2P9')));

    // showCustomAlertDialog의 확인 버튼이 go_router의 context.pop()을 쓰므로
    // 순수 MaterialApp이 아닌 GoRouter 하네스가 필요하다.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: LayoutBuilder(
              builder: (_, constraints) => PendingMemberModal(
                storeId: store.id,
                maxAvailableHeight: 600,
              ),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeDetailProvider(store.id).overrideWith((ref) async => store),
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // 코드가 없을 때는 재발급 버튼이 없다 — 첫 행의 [발급]이 같은 역할을 한다.
    expect(find.byTooltip('재발급'), findsNothing);

    await tester.tap(find.text('발급'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('재발급'), findsOneWidget);

    // 확인 다이얼로그의 버튼도 '재발급'이라 아이콘은 tooltip으로 찾는다.
    await tester.tap(find.byTooltip('재발급'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('재발급'));
    await tester.pumpAndSettle();

    verify(
      () => mockStoreUseCase.createInviteCode(store.id, forceRegenerate: true),
    ).called(1);
  });

  /// 저장된 초대 코드를 가진 점포로 모달을 띄운다.
  Future<void> pumpWithSavedInvite(WidgetTester tester, Store store) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeDetailProvider(store.id).overrideWith((ref) async => store),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (_, constraints) => PendingMemberModal(
                storeId: store.id,
                maxAvailableHeight: 600,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('저장된 코드의 유효 기간이 남았으면 열자마자 보여준다', (tester) async {
    final store = storeWithWaiting([]).copyWith(
      inviteInfo: InviteInfo(
        inviteCode: 'A7K2P9',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );

    await pumpWithSavedInvite(tester, store);

    expect(find.text('A7K2P9'), findsOneWidget);
    expect(find.text('발급'), findsNothing);
  });

  testWidgets('저장된 코드가 만료됐으면 발급 상태로 시작한다', (tester) async {
    final store = storeWithWaiting([]).copyWith(
      inviteInfo: InviteInfo(
        inviteCode: 'A7K2P9',
        createdAt: DateTime.now().subtract(
          const Duration(minutes: storeInviteCodeAvailableMin + 1),
        ),
      ),
    );

    await pumpWithSavedInvite(tester, store);

    expect(find.text('A7K2P9'), findsNothing);
    expect(find.text('발급'), findsOneWidget);
  });

  testWidgets('createdAt을 모르는 저장된 코드는 만료를 판단할 수 없어 숨긴다', (tester) async {
    final store = storeWithWaiting(
      [],
    ).copyWith(inviteInfo: const InviteInfo(inviteCode: 'A7K2P9'));

    await pumpWithSavedInvite(tester, store);

    expect(find.text('A7K2P9'), findsNothing);
    expect(find.text('발급'), findsOneWidget);
  });
}
