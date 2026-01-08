// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingViewModel)
final onboardingViewModelProvider = OnboardingViewModelProvider._();

final class OnboardingViewModelProvider
    extends
        $NotifierProvider<OnboardingViewModel, AsyncValue<OnboardingState>> {
  OnboardingViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingViewModelHash();

  @$internal
  @override
  OnboardingViewModel create() => OnboardingViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<OnboardingState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<OnboardingState>>(value),
    );
  }
}

String _$onboardingViewModelHash() =>
    r'2d6c9910388c7e4e3c24f3db530e17718d30f409';

abstract class _$OnboardingViewModel
    extends $Notifier<AsyncValue<OnboardingState>> {
  AsyncValue<OnboardingState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<OnboardingState>, AsyncValue<OnboardingState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OnboardingState>,
                AsyncValue<OnboardingState>
              >,
              AsyncValue<OnboardingState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
