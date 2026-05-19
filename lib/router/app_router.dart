import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/commons/admin_store_registration/screens/admin_store_registration_screen.dart';
import 'package:studio_chance/presentation/commons/invite_code/screens/invite_code_input_screen.dart';
import 'package:studio_chance/presentation/commons/invite_code/screens/invite_code_verified_screen.dart';
import 'package:studio_chance/presentation/commons/role_selection/screens/role_selection_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/price_days_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/price_time_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/payment_info_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_address_input_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_color_selection_screen.dart';
import 'package:studio_chance/presentation/commons/store_input/screens/store_form_screen.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/home/screens/confirmation_notice_screen.dart';
import 'package:studio_chance/presentation/home/screens/home_screen.dart';
import 'package:studio_chance/presentation/home/screens/payment_instruction_screen.dart';
import 'package:studio_chance/presentation/onboarding/screens/onboarding_nickname_screen.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/sign_in/screens/sign_in_screen.dart';
import 'package:studio_chance/presentation/splash/screens/splash_screen.dart';
import 'package:studio_chance/router/auth_listenable.dart';
import 'package:studio_chance/router/router_path.dart';

part 'app_router.g.dart';

/// 역할 선택 → 점포 등록/초대 코드 하위 라우트 (onboarding, myPage 공유)
List<GoRoute> _roleSubRoutes() => [
  GoRoute(
    path: SCRoute.adminStoreRegistration.path,
    builder: (context, state) => const AdminStoreRegistrationScreen(),
    routes: [
      // 점포 생성
      GoRoute(
        path: SCRoute.storeCreation.path,
        builder: (context, state) => const StoreFormScreen(),
        routes: [
          GoRoute(
            path: SCRoute.storeColor.path,
            builder: (context, state) => const StoreColorSelectionScreen(),
          ),
          GoRoute(
            path: SCRoute.storeAddress.path,
            builder: (context, state) => const StoreAddressInputScreen(),
          ),
          GoRoute(
            path: SCRoute.storePaymentInfo.path,
            builder: (context, state) => const PaymentInfoInputScreen(),
            routes: [
              GoRoute(
                path: SCRoute.paymentInstruction.path,
                builder: (context, state) => PaymentInstructionScreen(
                  previewStoreToEdit: state.extra as Store?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: SCRoute.storePriceDays.path,
            builder: (context, state) => const PriceDaysInputScreen(),
          ),
          GoRoute(
            path: SCRoute.storePriceTime.path,
            builder: (context, state) => const PriceTimeInputScreen(),
          ),
        ],
      ),
      // 초대 코드 입력 (admin)
      GoRoute(
        path: SCRoute.inviteCodeForm.path,
        builder: (context, state) => const InviteCodeInputScreen(),
        routes: [
          GoRoute(
            path: SCRoute.inviteCodeVerified.path,
            builder: (context, state) => const InviteCodeVerifiedScreen(),
          ),
        ],
      ),
    ],
  ),
  // 초대 코드 입력 (staff, viewer)
  GoRoute(
    path: SCRoute.inviteCodeForm.path,
    builder: (context, state) => const InviteCodeInputScreen(),
    routes: [
      GoRoute(
        path: SCRoute.inviteCodeVerified.path,
        builder: (context, state) => const InviteCodeVerifiedScreen(),
      ),
    ],
  ),
];

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
        routes: [
          GoRoute(
            path: SCRoute.paymentInstruction.path,
            builder: (context, state) => PaymentInstructionScreen(
              reservation: state.extra as Reservation?,
            ),
          ),
          GoRoute(
            path: SCRoute.confirmationNotice.path,
            builder: (context, state) => ConfirmationNoticeScreen(
              reservation: state.extra as Reservation,
            ),
          ),
        ],
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
          // 닉네임 설정
          GoRoute(
            path: SCRoute.onboardingNickname.path,
            name: SCRoute.onboardingNickname.name,
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const OnboardingNicknameScreen(),
            ),
          ),
          // 역할 선택 → 하위 라우트
          GoRoute(
            path: SCRoute.role.path,
            builder: (context, state) => const RoleSelectionScreen(),
            routes: _roleSubRoutes(),
          ),
        ],
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) {
      // 1. AuthController의 전체 상태(AsyncValue)를 가져옴
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
