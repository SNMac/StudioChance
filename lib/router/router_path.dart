import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

enum SCRoute {
  // ---------------------------------------------------------------------------
  // 최상위 라우트
  // ---------------------------------------------------------------------------
  splash,
  signIn,
  home,
  stats,
  myPage,

  // ---------------------------------------------------------------------------
  // 온보딩 전용
  // ---------------------------------------------------------------------------
  onboardingNickname,

  // ---------------------------------------------------------------------------
  // 공유 라우트 (onboarding, myPage 등 여러 컨텍스트에서 재사용)
  // - 이동 시 fullPath 대신 pushChild(context) 사용
  // ---------------------------------------------------------------------------
  nickname,
  role,
  adminStoreRegistration,
  storeCreation,
  storeColor,
  storeAddress,
  storePriceDays,
  storePriceTime,
  inviteCodeForm,
  inviteCodeVerified,
  paymentInstruction,
  confirmationNotice;

  /// [정의용] GoRoute path (상대 경로)
  String get path {
    switch (this) {
      case SCRoute.splash:
        return '/splash';
      case SCRoute.signIn:
        return '/sign-in';

      case SCRoute.home:
        return '/home';
      case SCRoute.stats:
        return '/stats';
      case SCRoute.myPage:
        return '/my-page';

      case SCRoute.onboardingNickname:
        return 'nickname';

      case SCRoute.nickname:
        return 'nickname';
      case SCRoute.role:
        return 'role';
      case SCRoute.adminStoreRegistration:
        return 'admin-store-registration';
      case SCRoute.storeCreation:
        return 'store-creation';
      case SCRoute.storeColor:
        return 'color';
      case SCRoute.storeAddress:
        return 'address';
      case SCRoute.storePriceDays:
        return 'price-days';
      case SCRoute.storePriceTime:
        return 'price-time';
      case SCRoute.inviteCodeForm:
        return 'invite-code-form';
      case SCRoute.inviteCodeVerified:
        return 'invite-code-verified';
      case SCRoute.paymentInstruction:
        return 'payment-instruction';
      case SCRoute.confirmationNotice:
        return 'confirmation-notice';
    }
  }

  /// [이동용] 절대 경로 — 최상위 및 온보딩 전용 라우트만 사용
  /// 공유 라우트는 `pushChild` 를 사용할 것
  String get fullPath {
    switch (this) {
      case SCRoute.splash:
        return '/splash';
      case SCRoute.signIn:
        return '/sign-in';

      case SCRoute.home:
        return '/home';
      case SCRoute.stats:
        return '/stats';
      case SCRoute.myPage:
        return '/my-page';

      case SCRoute.onboardingNickname:
        return '/onboarding/nickname';

      default:
        throw UnsupportedError(
          '$name 은 공유 라우트입니다. fullPath 대신 pushChild(context) 를 사용하세요.',
        );
    }
  }

  /// 현재 위치의 하위 경로로 push
  void pushChild(BuildContext context, {Object? extra}) {
    final currentPath = GoRouterState.of(context).uri.path;
    context.push('$currentPath/$path', extra: extra);
  }
}
