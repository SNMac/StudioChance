# 네비게이션 패턴 상세

## 목차
- [SCRoute Enum](#scroute-enum)
- [라우트 이동 방식](#라우트-이동-방식)
- [GoRouter 설정](#gorouter-설정)
- [인증 리다이렉트](#인증-리다이렉트)
- [AuthStreamListenable](#authstreamlistenable)
- [페이지 전환 애니메이션](#페이지-전환-애니메이션)
- [공유 서브라우트](#공유-서브라우트)

---

## SCRoute Enum

모든 라우트를 중앙 관리:

```dart
enum SCRoute {
  // 최상위 라우트 (fullPath 사용 가능)
  splash, signIn, home, onboardingNickname,

  // 공유 서브 라우트 (pushChild 사용)
  role, adminStoreRegistration, storeCreation,
  storeColor, storeAddress, storePriceDays, storePriceTime,
  invitation;

  // GoRoute 정의용 (상대 경로)
  String get path => switch (this) {
    SCRoute.splash => '/splash',
    SCRoute.signIn => '/sign-in',
    SCRoute.home => '/home',
    SCRoute.onboardingNickname => '/onboarding/nickname',
    SCRoute.role => 'role',
    SCRoute.storeCreation => 'store-creation',
    // ...
  };

  // 최상위 네비게이션용 (절대 경로)
  String get fullPath => switch (this) {
    SCRoute.splash => '/splash',
    SCRoute.signIn => '/sign-in',
    SCRoute.home => '/home',
    SCRoute.onboardingNickname => '/onboarding/nickname',
    _ => throw UnsupportedError('$name은(는) 공유 라우트입니다. pushChild()를 사용하세요.'),
  };

  // 현재 위치 기준 상대 이동
  void pushChild(BuildContext context, {Object? extra}) {
    final currentPath = GoRouterState.of(context).uri.path;
    context.push('$currentPath/$path', extra: extra);
  }
}
```

---

## 라우트 이동 방식

| 상황 | 메서드 | 예시 |
|------|--------|------|
| 최상위 라우트로 이동 | `context.go()` | `context.go(SCRoute.home.fullPath)` |
| 서브 라우트로 push | `pushChild()` | `SCRoute.role.pushChild(context)` |
| 뒤로 가기 | `context.pop()` | `if (context.canPop()) context.pop()` |
| 리다이렉트 (자동) | GoRouter redirect | `return SCRoute.signIn.path` |

### 주의사항

- 공유 서브 라우트에서 `fullPath`를 호출하면 `UnsupportedError` 발생
- `pushChild`는 현재 경로에 상대 경로를 붙여서 push
- `context.go()`는 스택을 교체, `context.push()`는 스택에 추가

---

## GoRouter 설정

```dart
@riverpod
GoRouter goRouter(Ref ref) {
  final authListenable = AuthStreamListenable(ref);

  return GoRouter(
    initialLocation: SCRoute.splash.path,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    routes: [
      GoRoute(
        path: SCRoute.splash.path,
        pageBuilder: (context, state) =>
          _fadePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: SCRoute.signIn.path,
        pageBuilder: (context, state) =>
          _fadePage(state: state, child: const SignInScreen()),
      ),
      GoRoute(
        path: SCRoute.home.path,
        pageBuilder: (context, state) =>
          _fadePage(state: state, child: const HomeScreen()),
      ),
      GoRoute(
        path: SCRoute.onboardingNickname.path,
        builder: (context, state) => const OnboardingNicknameScreen(),
        routes: [
          GoRoute(
            path: SCRoute.role.path,
            builder: (context, state) => const RoleSelectionScreen(),
            routes: _roleSubRoutes(),
          ),
        ],
      ),
    ],
    redirect: _authRedirect(ref),
  );
}
```

---

## 인증 리다이렉트

```dart
String? Function(BuildContext, GoRouterState) _authRedirect(Ref ref) {
  return (context, state) {
    final authState = ref.read(appAuthControllerProvider);
    if (authState.isLoading || authState.hasError) return null;

    final status = authState.value;
    if (status == null) return SCRoute.signIn.path;

    final location = state.uri.path;
    final isSplash = location == SCRoute.splash.path;
    final isLoggingIn = location == SCRoute.signIn.path;
    final isOnboarding = location.startsWith('/onboarding');

    return switch (status) {
      AppStatus.unauthenticated => isLoggingIn ? null : SCRoute.signIn.path,
      AppStatus.onboarding => isOnboarding ? null : SCRoute.onboardingNickname.fullPath,
      AppStatus.authenticated => (isSplash || isLoggingIn || isOnboarding)
        ? SCRoute.home.path : null,
      AppStatus.error => SCRoute.signIn.path,
    };
  };
}
```

---

## AuthStreamListenable

Riverpod → GoRouter 브리지:

```dart
class AuthStreamListenable extends ChangeNotifier {
  AuthStreamListenable(Ref ref) {
    ref.listen(appAuthControllerProvider, (previous, next) {
      notifyListeners(); // GoRouter의 redirect 재실행 트리거
    });
  }
}
```

---

## 페이지 전환 애니메이션

최상위 라우트만 fade 전환, 나머지는 기본 slide:

```dart
CustomTransitionPage _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
```

---

## 공유 서브라우트

여러 경로에서 재사용되는 서브라우트 트리:

```dart
List<GoRoute> _roleSubRoutes() => [
  GoRoute(
    path: SCRoute.adminStoreRegistration.path,
    builder: (context, state) => const AdminStoreRegistrationScreen(),
    routes: [
      GoRoute(
        path: SCRoute.storeCreation.path,
        builder: (context, state) => const StoreCreationScreen(),
        routes: [
          GoRoute(path: SCRoute.storeColor.path, ...),
          GoRoute(path: SCRoute.storeAddress.path, ...),
          GoRoute(path: SCRoute.storePriceDays.path, ...),
          GoRoute(path: SCRoute.storePriceTime.path, ...),
        ],
      ),
      GoRoute(path: SCRoute.invitation.path, ...),
    ],
  ),
  GoRoute(path: SCRoute.invitation.path, ...), // staff/viewer 초대 코드
];
```
