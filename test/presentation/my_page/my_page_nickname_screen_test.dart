import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
import 'package:studio_chance/presentation/my_page/screens/my_page_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

import '../../helpers/fake_entities.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockUserUseCase mockUserUseCase;

  setUp(() {
    mockUserUseCase = MockUserUseCase();
    when(() => mockUserUseCase.getCurrentUser())
        .thenAnswer((_) async => right(fakeUser));
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/my-page/nickname',
      routes: [
        GoRoute(
          path: '/my-page',
          builder: (_, _) => const Scaffold(body: Text('마이페이지 본문')),
          routes: [
            GoRoute(
              path: 'nickname',
              builder: (_, _) => const MyPageNicknameScreen(),
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) async => fakeUser),
        userUseCaseProvider.overrideWith((ref) => mockUserUseCase),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('닉네임을 저장하면 마이페이지로 돌아간다', (tester) async {
    // 실제 Firestore 쓰기처럼 시간이 걸리는 동안 화면이 컨트롤러를 붙잡고 있어야 한다.
    when(
      () => mockUserUseCase.updateUser(
        uid: any(named: 'uid'),
        nickname: any(named: 'nickname'),
      ),
    ).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 100),
        () => right<Exception, void>(null),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    verify(
      () => mockUserUseCase.updateUser(
        uid: fakeUser.id,
        nickname: fakeUser.nickname,
      ),
    ).called(1);
    expect(find.text('마이페이지 본문'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('닉네임 저장에 실패하면 오류 다이얼로그로 알리고 화면에 남는다', (tester) async {
    when(
      () => mockUserUseCase.updateUser(
        uid: any(named: 'uid'),
        nickname: any(named: 'nickname'),
      ),
    ).thenAnswer((_) async => left(Exception('네트워크 오류')));

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    // 본문은 showCustomAlertDialog가 글자 사이에 ZWJ를 넣어 정확히 매칭되지 않으므로
    // title만 검증한다.
    expect(find.text('오류'), findsOneWidget);
    expect(find.text('마이페이지 본문'), findsNothing);
  });
}
