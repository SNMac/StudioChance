// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, FutureOr<User?>>
    with $FutureModifier<User?>, $FutureProvider<User?> {
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $FutureProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'40ade47ca586ca482d479b25ce12f1ab254be201';

@ProviderFor(AppAuthController)
final appAuthControllerProvider = AppAuthControllerProvider._();

final class AppAuthControllerProvider
    extends $AsyncNotifierProvider<AppAuthController, AppStatus> {
  AppAuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appAuthControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appAuthControllerHash();

  @$internal
  @override
  AppAuthController create() => AppAuthController();
}

String _$appAuthControllerHash() => r'1873a05f609dd35a73cbdeae734bf1e717f8ab6e';

abstract class _$AppAuthController extends $AsyncNotifier<AppStatus> {
  FutureOr<AppStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppStatus>, AppStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppStatus>, AppStatus>,
              AsyncValue<AppStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
