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
    extends $NotifierProvider<StoreCreationController, StoreFormState> {
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
  Override overrideWithValue(StoreFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreFormState>(value),
    );
  }
}

String _$storeCreationControllerHash() =>
    r'bba5c0a1fbfed5122e0995ad8c6f8d0f5bf8385f';

abstract class _$StoreCreationController extends $Notifier<StoreFormState> {
  StoreFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StoreFormState, StoreFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoreFormState, StoreFormState>,
              StoreFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
