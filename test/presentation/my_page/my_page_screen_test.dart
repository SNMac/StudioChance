import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/common/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/my_page/screens/my_page_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

import '../../helpers/fake_entities.dart';

class MockStoreUseCase extends Mock implements StoreUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserRole.staff);
  });

  // MyPageScreen은 bottomNavigationBar로 HomeTabBar를 포함하고,
  // HomeTabBar는 GoRouterState.of(context)를 호출하므로 GoRouter 없이는 pump 시 즉시 throw한다.
  // showCustomAlertDialog의 확인 버튼도 go_router의 context.pop()을 쓰므로
  // (custom_alert_dialog.dart) 어차피 GoRouter 하네스가 필요하다.
  Widget wrap(MockStoreUseCase mockStoreUseCase) {
    final router = GoRouter(
      initialLocation: '/my-page',
      routes: [
        GoRoute(path: '/my-page', builder: (_, _) => const MyPageScreen()),
      ],
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) async => fakeUser),
        storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('승인 실패 시 오류 다이얼로그로 사용자에게 알린다', (tester) async {
    final mockStoreUseCase = MockStoreUseCase();
    final store = fakeStore.copyWith(
      waitingMemberInfos: [
        StoreMemberInfo(
          user: fakeUser.copyWith(id: 'applicant-1', nickname: '홍길동'),
          role: UserRole.staff,
        ),
      ],
    );
    when(
      () => mockStoreUseCase.getStore(any()),
    ).thenAnswer((_) async => right(store));
    when(
      () => mockStoreUseCase.approveMember(
        storeId: any(named: 'storeId'),
        targetUid: any(named: 'targetUid'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) async => left(Exception('네트워크 오류')));

    await tester.pumpWidget(wrap(mockStoreUseCase));
    await tester.pumpAndSettle();

    // 관리자 점포 행 탭 → 승인 대기 모달
    await tester.tap(find.text('테스트 점포'));
    await tester.pumpAndSettle();

    // 승인 → 확인 다이얼로그 → 확인 → approve() 실패
    await tester.tap(find.text('승인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // PendingMemberController 상태가 AsyncError로 끝나는 것만으로는 부족하고,
    // MyPageScreen의 ref.listen이 실제로 오류 다이얼로그를 띄우는지까지 확인한다.
    // (본문은 showCustomAlertDialog가 insertZwj()로 글자 사이에 ZWJ를 삽입해
    // 정확한 문자열 매칭이 되지 않으므로 title만 검증한다.)
    expect(find.text('오류'), findsOneWidget);
  });
}
