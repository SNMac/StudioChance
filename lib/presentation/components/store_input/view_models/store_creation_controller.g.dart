// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_creation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreCreationController)
final storeCreationControllerProvider = StoreCreationControllerProvider._();

final class StoreCreationControllerProvider
    extends $NotifierProvider<StoreCreationController, AsyncValue<void>> {
  StoreCreationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeCreationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeCreationControllerHash();

  @$internal
  @override
  StoreCreationController create() => StoreCreationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$storeCreationControllerHash() =>
    r'74f44f1d238bcd608839575e049a269d855e1f9c';

abstract class _$StoreCreationController extends $Notifier<AsyncValue<void>> {
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
