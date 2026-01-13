// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingSessionController)
final onboardingSessionControllerProvider =
    OnboardingSessionControllerProvider._();

final class OnboardingSessionControllerProvider
    extends
        $NotifierProvider<OnboardingSessionController, OnboardingSessionState> {
  OnboardingSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSessionControllerHash();

  @$internal
  @override
  OnboardingSessionController create() => OnboardingSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingSessionState>(value),
    );
  }
}

String _$onboardingSessionControllerHash() =>
    r'3c83c2bbf8547e50fe4f8f39730a27dc75597a47';

abstract class _$OnboardingSessionController
    extends $Notifier<OnboardingSessionState> {
  OnboardingSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<OnboardingSessionState, OnboardingSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingSessionState, OnboardingSessionState>,
              OnboardingSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
