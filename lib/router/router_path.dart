enum SCRoute {
  splash,
  signIn,
  home,
  onboardingNickname,
  onboardingRole,
  onboardingAdmin,
  onboardingStore,
  onboardingStoreColor,
  onboardingStoreAddress,
  onboardingPriceDays,
  onboardingInvitation;

  /// [정의용] GoRoute path (상대 경로)
  String get path {
    switch (this) {
      case SCRoute.splash:
        return '/splash';
      case SCRoute.signIn:
        return '/sign-in';
      case SCRoute.home:
        return '/home';

      case SCRoute.onboardingNickname:
        return 'nickname';
      case SCRoute.onboardingRole:
        return 'role';
      case SCRoute.onboardingAdmin:
        return 'admin';
      case SCRoute.onboardingStore:
        return 'store';
      case SCRoute.onboardingStoreColor:
        return 'color';
      case SCRoute.onboardingStoreAddress:
        return 'address';
      case SCRoute.onboardingPriceDays:
        return 'price-days';
      case SCRoute.onboardingInvitation:
        return 'invitation';
    }
  }

  /// [이동용] Redirect / Context.push (절대 경로)
  String get fullPath {
    switch (this) {
      case SCRoute.splash:
        return '/splash';
      case SCRoute.signIn:
        return '/sign-in';
      case SCRoute.home:
        return '/home';

      case SCRoute.onboardingNickname:
        return '/onboarding/nickname';
      case SCRoute.onboardingRole:
        return '/onboarding/role';
      case SCRoute.onboardingAdmin:
        return '/onboarding/admin';
      case SCRoute.onboardingStore:
        return '/onboarding/store';
      case SCRoute.onboardingStoreColor:
        return '/onboarding/store/color';
      case SCRoute.onboardingStoreAddress:
        return '/onboarding/store/address';
      case SCRoute.onboardingPriceDays:
        return '/onboarding/store/price-days';
      case SCRoute.onboardingInvitation:
        return '/onboarding/invitation';
    }
  }
}
