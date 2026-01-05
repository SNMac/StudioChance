import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/providers/auth_state_provider.dart';
import 'package:studio_chance/presentation/sign_in/views/sign_in_view.dart';
import 'package:studio_chance/presentation/home/views/home_view.dart';
import 'package:studio_chance/presentation/onboarding/views/nickname_view.dart';

part 'app_router.g.dart';

enum SCRoute {
  signIn,
  onboarding,
  home;

  String get path {
    switch (this) {
      case SCRoute.signIn:
        return '/sign_in';
      case SCRoute.home:
        return '/home';
      case SCRoute.onboarding:
        return 'onboarding';
    }
  }

  String get fullPath {
    switch (this) {
      case SCRoute.signIn:
        return '/sign_in';
      case SCRoute.home:
        return '/home';
      case SCRoute.onboarding:
        return '/sign_in/onboarding';
    }
  }
}

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: SCRoute.signIn.fullPath,
    routes: <GoRoute>[
      GoRoute(
        path: SCRoute.signIn.path,
        builder: (context, state) => const SignInView(),
        routes: [
          GoRoute(
            path: SCRoute.onboarding.path,
            builder: (context, state) => const NicknameView(),
          ),
        ],
      ),
      GoRoute(
        path: SCRoute.home.path,
        builder: (context, state) => const HomeView(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      if (authState.isLoading) return null;
      FlutterNativeSplash.remove();

      if (authState.hasError) return SCRoute.signIn.fullPath;

      final user = authState.value;
      final isLoggedIn = user != null;

      final isGoingToSignIn = state.matchedLocation == SCRoute.signIn.fullPath;
      final isGoingToOnboarding =
          state.matchedLocation == SCRoute.onboarding.fullPath;

      if (!isLoggedIn) {
        return isGoingToSignIn ? null : SCRoute.signIn.fullPath;
      }

      if (isLoggedIn) {
        // 신규 사용자 (온보딩 필요 사용자)
        if (user.isNewUser) {
          return isGoingToOnboarding ? null : SCRoute.onboarding.fullPath;
        }

        // 기존 사용자
        if (isGoingToSignIn || isGoingToOnboarding) {
          return SCRoute.home.fullPath;
        }
      }

      return null;
    },
  );
}
