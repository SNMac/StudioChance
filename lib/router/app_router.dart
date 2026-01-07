import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/home/views/home_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_invitation_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_nickname_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_role_view.dart';
import 'package:studio_chance/presentation/onboarding/views/onboarding_store_view.dart';
import 'package:studio_chance/presentation/providers/auth_state_provider.dart';
import 'package:studio_chance/presentation/sign_in/views/sign_in_view.dart';
import 'package:studio_chance/presentation/splash/views/splash_view.dart';
import 'package:studio_chance/router/auth_notifier.dart';
import 'package:studio_chance/router/router_path.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final onboardingRoutes = [
    GoRoute(
      path: SCRoute.onboardingNickname.path,
      builder: (context, state) => const OnboardingNicknameView(),
    ),
    GoRoute(
      path: SCRoute.onboardingRole.path,
      builder: (context, state) => const OnboardingRoleView(),
    ),
    GoRoute(
      path: SCRoute.onboardingStore.path,
      builder: (context, state) => const OnboardingStoreView(),
    ),
    GoRoute(
      path: SCRoute.onboardingInvitation.path,
      builder: (context, state) => const OnboardingInvitationView(),
    ),
  ];

  return GoRouter(
    initialLocation: SCRoute.signIn.path,
    debugLogDiagnostics: true,
    refreshListenable: AuthNotifier(ref),
    routes: <GoRoute>[
      GoRoute(
        path: SCRoute.splash.path,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: SCRoute.signIn.path,
        builder: (context, state) => const SignInView(),
        routes: onboardingRoutes,
      ),
      GoRoute(
        path: SCRoute.home.path,
        builder: (context, state) => const HomeView(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return null;
      if (authState.hasError) return SCRoute.signIn.fullPath;

      final user = authState.value;
      final isLoggedIn = user != null;

      final isGoingToSignIn = state.matchedLocation == SCRoute.signIn.fullPath;

      final isGoingToOnboardingFlow = state.matchedLocation.contains(
        'onboarding',
      );

      if (!isLoggedIn) {
        return isGoingToSignIn ? null : SCRoute.signIn.fullPath;
      }

      // 신규 사용자
      if (user.isNewUser) {
        return isGoingToOnboardingFlow
            ? null
            : SCRoute.onboardingNickname.fullPath;
      }

      // 기존 사용자
      if (isGoingToSignIn || isGoingToOnboardingFlow) {
        return SCRoute.home.fullPath;
      }

      return null;
    },
  );
}
