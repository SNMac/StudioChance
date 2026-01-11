// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$appAuthControllerHash() => r'acc4f7d4070d6d2f61481c76bed9ed85c38ea300';

abstract class _$AppAuthController extends $AsyncNotifier<AppStatus> {
  FutureOr<AppStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppStatus>, AppStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppStatus>, AppStatus>,
              AsyncValue<AppStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
