// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_nickname_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingNicknameController)
final onboardingNicknameControllerProvider =
    OnboardingNicknameControllerProvider._();

final class OnboardingNicknameControllerProvider
    extends $AsyncNotifierProvider<OnboardingNicknameController, void> {
  OnboardingNicknameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingNicknameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNicknameControllerHash();

  @$internal
  @override
  OnboardingNicknameController create() => OnboardingNicknameController();
}

String _$onboardingNicknameControllerHash() =>
    r'72cfad93d50124069a1a1b1412227254d24d9a6c';

abstract class _$OnboardingNicknameController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
