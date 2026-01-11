// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingSession)
final onboardingSessionProvider = OnboardingSessionProvider._();

final class OnboardingSessionProvider
    extends $NotifierProvider<OnboardingSession, OnboardingState> {
  OnboardingSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSessionHash();

  @$internal
  @override
  OnboardingSession create() => OnboardingSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingSessionHash() => r'785ace59027426d2a0d70eee34d6b9074a90b091';

abstract class _$OnboardingSession extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingState, OnboardingState>,
              OnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
