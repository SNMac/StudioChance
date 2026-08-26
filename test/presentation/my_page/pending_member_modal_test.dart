import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

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

  testWidgets('대기자가 없으면 안내 문구를 보여준다', (tester) async {
    final store = storeWithWaiting([]);

    await tester.pumpWidget(
      wrap(
        PendingMemberModal(storeId: store.id, maxAvailableHeight: 600),
        store: store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('대기 중인 가입 신청이 없습니다.'), findsOneWidget);
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
}
