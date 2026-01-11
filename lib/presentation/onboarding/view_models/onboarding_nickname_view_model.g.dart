// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_nickname_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingNicknameViewModel)
final onboardingNicknameViewModelProvider =
    OnboardingNicknameViewModelProvider._();

final class OnboardingNicknameViewModelProvider
    extends $NotifierProvider<OnboardingNicknameViewModel, String> {
  OnboardingNicknameViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingNicknameViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNicknameViewModelHash();

  @$internal
  @override
  OnboardingNicknameViewModel create() => OnboardingNicknameViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$onboardingNicknameViewModelHash() =>
    r'b38307f3821065ccaf530222034d5cc55dcbba99';

abstract class _$OnboardingNicknameViewModel extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
