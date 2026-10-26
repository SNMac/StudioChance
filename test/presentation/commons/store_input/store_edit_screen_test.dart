import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/common/exceptions/store_exceptions.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/router/router_path.dart';

import '../../../helpers/fake_entities.dart';
import '../../../helpers/mocks.dart';

// fakeStore의 공간은 이름이 비어 있어 저장 버튼이 활성화되지 않는다
final opened = fakeStore.copyWith(
  spaceOptions: [fakeStore.spaceOptions.first.copyWith(name: '기본 공간')],
);

void main() {
  late MockStoreUseCase mockStoreUseCase;
  bool? editResult;

  setUpAll(() {
    registerFallbackValue(fakeStore);
    registerFallbackValue(StoreColor.red);
  });

  setUp(() {
    mockStoreUseCase = MockStoreUseCase();
    editResult = null;
  });

  /// 실제 앱처럼 다른 화면 위에 `/store-edit`를 push하고 결과를 기록한다
  Future<void> openEditScreen(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  editResult = await pushStoreEdit(context, opened),
              child: const Text('수정 열기'),
            ),
          ),
        ),
        GoRoute(
          path: SCRoute.storeEdit.path,
          builder: (context, state) {
            final args = state.extra! as StoreEditArgs;
            return StoreFormScreen(storeToEdit: args.store);
          },
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
    await tester.tap(find.text('수정 열기'));
    await tester.pumpAndSettle();
  }

  void stubUpdate(Either<Exception, void> result) {
    when(
      () => mockStoreUseCase.updateStore(
        original: any(named: 'original'),
        store: any(named: 'store'),
        color: any(named: 'color'),
        memo: any(named: 'memo'),
      ),
    ).thenAnswer((_) async => result);
  }

  testWidgets('저장에 성공하면 수정 화면을 닫고 저장했다고 알린다', (tester) async {
    stubUpdate(right(null));
    await openEditScreen(tester);

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(find.text('수정 열기'), findsOneWidget);
    expect(editResult, isTrue);
  });

  testWidgets('뒤로 가기 확인 후 닫으면 저장하지 않았다고 알린다', (tester) async {
    await openEditScreen(tester);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.text('수정 열기'), findsOneWidget);
    expect(editResult, isFalse);
  });

  testWidgets('다른 관리자가 먼저 저장했으면 확인 후 최신 값으로 폼을 다시 채운다', (tester) async {
    stubUpdate(left(StoreUpdateConflictException(message: '충돌')));
    final latest = opened.copyWith(name: '다른 관리자가 바꾼 이름');
    when(() => mockStoreUseCase.getStoreForEdit(opened.id))
        .thenAnswer((_) async => right<Exception, Store>(latest));
    await openEditScreen(tester);

    await tester.enterText(find.widgetWithText(TextField, opened.name), '내 이름');
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '다른 관리자가 바꾼 이름'), findsOneWidget);
    expect(find.widgetWithText(TextField, '내 이름'), findsNothing);
    // 화면은 그대로 남아 사용자가 다시 고칠 수 있다
    expect(find.text('수정 열기'), findsNothing);
  });
}
