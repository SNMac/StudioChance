import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studio_chance/my_app.dart';
import 'package:studio_chance/presentation/providers/notification_controller.dart';
import 'package:studio_chance/router/app_router.dart';

/// 알림 권한 요청·토큰 등록을 하지 않는다
class _NoopNotificationController extends NotificationController {
  @override
  Future<void> build() async {}
}

void main() {
  // go_router 18은 조상의 material_ui `MaterialApp`을 찾아 앱 종류를 판별한다.
  // MyApp이 다른 `MaterialApp`(flutter/material)을 쓰면 컴파일은 되지만 `builder:` 라우트가
  // 전환 애니메이션 없는 `NoTransitionPage`로 만들어진다 (#72)
  testWidgets('builder: 라우트는 플랫폼 기본 전환을 쓰는 MaterialPage로 만들어진다', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('홈')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goRouterProvider.overrideWithValue(router),
          notificationControllerProvider.overrideWith(
            _NoopNotificationController.new,
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    final route = ModalRoute.of(tester.element(find.text('홈')));
    expect(route?.settings, isA<MaterialPage<void>>());
  });
}
