// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_role_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingRoleViewModel)
final onboardingRoleViewModelProvider = OnboardingRoleViewModelProvider._();

final class OnboardingRoleViewModelProvider
    extends $NotifierProvider<OnboardingRoleViewModel, UserRole> {
  OnboardingRoleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRoleViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRoleViewModelHash();

  @$internal
  @override
  OnboardingRoleViewModel create() => OnboardingRoleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRole>(value),
    );
  }
}

String _$onboardingRoleViewModelHash() =>
    r'0b17b98dcdd10d5b822ed10af4ece9dbc8612fbe';

abstract class _$OnboardingRoleViewModel extends $Notifier<UserRole> {
  UserRole build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserRole, UserRole>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserRole, UserRole>,
              UserRole,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
