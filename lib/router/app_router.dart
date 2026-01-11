import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/home/views/home_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_invitation_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_nickname_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_role_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_store_view.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/sign_in/views/sign_in_view.dart';
import 'package:studio_chance/presentation/splash/views/splash_view.dart';
import 'package:studio_chance/router/auth_listenable.dart';
import 'package:studio_chance/router/router_path.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authListenable = AuthStreamListenable(ref);

  return GoRouter(
    initialLocation: SCRoute.splash.path,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    routes: <GoRoute>[
      // 스플래시
      GoRoute(
        path: SCRoute.splash.path,
        name: SCRoute.splash.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SplashView()),
      ),

      // 로그인
      GoRoute(
        path: SCRoute.signIn.path,
        name: SCRoute.signIn.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SignInView()),
      ),

      // 홈
      GoRoute(
        path: SCRoute.home.path,
        name: SCRoute.home.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const HomeView()),
      ),

      // 온보딩 섹션
      GoRoute(
        path: '/onboarding',
        redirect: (context, state) {
          if (state.fullPath == '/onboarding') {
            return '/onboarding/nickname';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: SCRoute.onboardingNickname.path,
            name: SCRoute.onboardingNickname.name,
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const OnboardingNicknameView()),
          ),

          GoRoute(
            path: SCRoute.onboardingRole.path,
            name: SCRoute.onboardingRole.name,
            builder: (context, state) => const OnboardingRoleView(),
          ),

          GoRoute(
            path: SCRoute.onboardingStore.path,
            name: SCRoute.onboardingStore.name,
            builder: (context, state) => const OnboardingStoreView(),
          ),

          GoRoute(
            path: SCRoute.onboardingInvitation.path,
            name: SCRoute.onboardingInvitation.name,
            builder: (context, state) => const OnboardingInvitationView(),
          ),
        ],
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) {
      // 1. AuthController의 전체 상태(AsyncValue)를 기져옴
      final authState = ref.read(appAuthControllerProvider);

      // 2. [Case 1] 로딩 중이거나 에러가 났을 때
      if (authState.isLoading || authState.hasError) {
        return null; // 현재 위치(Splash) 유지
      }

      // 3. 로딩이 완료 이후 실제 데이터(AppStatus)를 꺼냄
      final status = authState.value;

      // 만약 데이터가 null이라면(예외 상황) 로그인으로 이동
      if (status == null) {
        return SCRoute.signIn.path;
      }

      final isSplash = state.matchedLocation == SCRoute.splash.path;
      final isLoggingIn = state.matchedLocation == SCRoute.signIn.path;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');
      final isHome = state.matchedLocation == SCRoute.home.path;

      // [Case 2] 로그인 필요
      if (status == AppStatus.unauthenticated) {
        // 이미 로그인 화면이면 유지, 아니면 로그인 화면으로 이동
        return isLoggingIn ? null : SCRoute.signIn.path;
      }

      // [Case 3] 온보딩 필요 (로그인 O, 닉네임 X)
      if (status == AppStatus.onboarding) {
        // 이미 온보딩 중이면 유지, 아니면 온보딩 시작점으로 이동
        return isOnboarding ? null : SCRoute.onboardingNickname.fullPath;
      }

      // [Case 4] 인증 완료 (로그인 O, 닉네임 O)
      if (status == AppStatus.authenticated) {
        // 로그인/스플래시/온보딩 화면에 있었다면 홈으로 이동
        if (isSplash || isLoggingIn || isOnboarding) {
          return SCRoute.home.path;
        }
      }

      return null;
    },
  );
}

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
