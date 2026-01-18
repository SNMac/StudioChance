import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/price_days_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_address_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_color_selection_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/presentation/home/screens/home_screen.dart';

import 'package:studio_chance/presentation/onboarding/screens/onboarding_admin_screen.dart';
import 'package:studio_chance/presentation/onboarding/screens/onboarding_invitation_screen.dart';
import 'package:studio_chance/presentation/onboarding/screens/onboarding_nickname_screen.dart';
import 'package:studio_chance/presentation/onboarding/screens/onboarding_role_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/sign_in/screens/sign_in_screen.dart';
import 'package:studio_chance/presentation/splash/screens/splash_screen.dart';
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
            _fadePage(state: state, child: const SplashScreen()),
      ),

      // 로그인
      GoRoute(
        path: SCRoute.signIn.path,
        name: SCRoute.signIn.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SignInScreen()),
      ),

      // 홈
      GoRoute(
        path: SCRoute.home.path,
        name: SCRoute.home.name,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const HomeScreen()),
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
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const OnboardingNicknameScreen(),
            ),
          ),
          GoRoute(
            path: SCRoute.onboardingRole.path,
            name: SCRoute.onboardingRole.name,
            builder: (context, state) => const OnboardingRoleScreen(),
          ),
          GoRoute(
            path: SCRoute.onboardingAdmin.path,
            name: SCRoute.onboardingAdmin.name,
            builder: (context, state) => const OnboardingAdminScreen(),
          ),
          GoRoute(
            path: SCRoute.onboardingStore.path,
            name: SCRoute.onboardingStore.name,
            builder: (context, state) => const StoreFormScreen(),
            routes: [
              GoRoute(
                path: SCRoute.onboardingStoreColor.path,
                name: SCRoute.onboardingStoreColor.name,
                builder: (context, state) => const StoreColorSelectionScreen(),
              ),
              GoRoute(
                path: SCRoute.onboardingStoreAddress.path,
                name: SCRoute.onboardingStoreAddress.name,
                builder: (context, state) => const StoreAddressInputScreen(),
              ),
              GoRoute(
                path: SCRoute.onboardingPriceDays.path,
                name: SCRoute.onboardingPriceDays.name,
                builder: (context, state) => const PriceDaysInputScreen(),
              ),
            ],
          ),
          GoRoute(
            path: SCRoute.onboardingInvitation.path,
            name: SCRoute.onboardingInvitation.name,
            builder: (context, state) => const OnboardingInvitationScreen(),
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
