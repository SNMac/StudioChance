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
import 'package:studio_chance/router/router_path.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authListenable = _AuthStreamListenable(ref);

  return GoRouter(
    initialLocation: SCRoute.signIn.path,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    routes: <GoRoute>[
      GoRoute(
        path: SCRoute.splash.path,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: SCRoute.signIn.path,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: SCRoute.home.path,
        builder: (context, state) => const HomeView(),
      ),

      GoRoute(
        path: '/onboarding',
        redirect: (context, state) => SCRoute.onboardingNickname.fullPath,
        routes: [
          GoRoute(
            path: 'nickname',
            builder: (context, state) => const OnboardingNicknameView(),
            routes: [
              GoRoute(
                path: SCRoute.onboardingRole.path,
                builder: (context, state) => const OnboardingRoleView(),
                routes: [
                  GoRoute(
                    path: SCRoute.onboardingStore.path,
                    builder: (context, state) => const OnboardingStoreView(),
                  ),
                  GoRoute(
                    path: SCRoute.onboardingInvitation.path,
                    builder: (context, state) =>
                        const OnboardingInvitationView(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final status =
          ref.read(appAuthControllerProvider).value ??
          AppStatus.unauthenticated;
      final isSplash = state.matchedLocation == SCRoute.splash.path;
      final isLoggingIn = state.matchedLocation == SCRoute.signIn.path;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');
      final isHome = state.matchedLocation == SCRoute.home.path;

      // [Case 1] 로딩 중 (스플래시 유지)
      if (status == AppStatus.authenticating) {
        return null; // 스플래시에 머무름
      }

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
        // 로그인/스플래시/온보딩 화면에 있었다면 홈으로 보냄
        if (isSplash || isLoggingIn || isOnboarding) {
          return SCRoute.home.path;
        }
      }

      return null;
    },
  );
}

class _AuthStreamListenable extends ChangeNotifier {
  _AuthStreamListenable(Ref ref) {
    ref.listen(appAuthControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}
