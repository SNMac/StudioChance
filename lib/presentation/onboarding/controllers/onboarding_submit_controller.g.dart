// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_submit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingSubmitController)
final onboardingSubmitControllerProvider =
    OnboardingSubmitControllerProvider._();

final class OnboardingSubmitControllerProvider
    extends $NotifierProvider<OnboardingSubmitController, AsyncValue<void>> {
  OnboardingSubmitControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSubmitControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSubmitControllerHash();

  @$internal
  @override
  OnboardingSubmitController create() => OnboardingSubmitController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$onboardingSubmitControllerHash() =>
    r'd4bb2ff3c1a337235e0eb62eb01d5f359c6885a8';

abstract class _$OnboardingSubmitController
    extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
