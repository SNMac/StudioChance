import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

import '../../../helpers/fake_entities.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockStoreUseCase mockStoreUseCase;

  setUpAll(() {
    registerFallbackValue(fakeStore);
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    when(
      () => mockStoreUseCase.createStore(
        store: any(named: 'store'),
        color: any(named: 'color'),
        memo: any(named: 'memo'),
      ),
    ).thenAnswer((_) async => right(fakeStore));
  });

  /// [parentPath] 아래의 점포 생성 화면을 열고 필수 항목을 채운다
  Future<void> openFilledCreationScreen(
    WidgetTester tester, {
    required String parentPath,
  }) async {
    final router = GoRouter(
      initialLocation: '$parentPath/create',
      routes: [
        GoRoute(
          path: parentPath,
          builder: (context, state) => const Scaffold(body: Text('상위 화면')),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const StoreFormScreen(),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeUseCaseProvider.overrideWith((ref) => mockStoreUseCase),
          currentUserProvider.overrideWith((ref) async => fakeUser),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(StoreFormScreen)),
    );
    container.read(storeCreationControllerProvider.notifier)
      ..setName('새 점포')
      ..setAddress('서울');
    await tester.pumpAndSettle();
  }

  testWidgets('마이페이지에서 연 점포 생성은 완료하면 마이페이지로 돌아간다', (tester) async {
    await openFilledCreationScreen(tester, parentPath: '/my-page');

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    verify(
      () => mockStoreUseCase.createStore(
        store: any(named: 'store'),
        color: any(named: 'color'),
        memo: any(named: 'memo'),
      ),
    ).called(1);
    expect(find.byType(StoreFormScreen), findsNothing);
    expect(find.text('상위 화면'), findsOneWidget);
  });

  testWidgets('온보딩에서 연 점포 생성은 직접 이동하지 않고 라우터 redirect에 맡긴다', (tester) async {
    await openFilledCreationScreen(tester, parentPath: '/onboarding');

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.byType(StoreFormScreen), findsOneWidget);
  });
}
