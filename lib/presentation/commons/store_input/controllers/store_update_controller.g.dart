// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreUpdateController)
final storeUpdateControllerProvider = StoreUpdateControllerFamily._();

final class StoreUpdateControllerProvider
    extends $NotifierProvider<StoreUpdateController, StoreFormState> {
  StoreUpdateControllerProvider._({
    required StoreUpdateControllerFamily super.from,
    required Store super.argument,
  }) : super(
         retry: null,
         name: r'storeUpdateControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeUpdateControllerHash();

  @override
  String toString() {
    return r'storeUpdateControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StoreUpdateController create() => StoreUpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StoreUpdateControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeUpdateControllerHash() =>
    r'60616392931039892494d4d9cfd86484f14444d4';

final class StoreUpdateControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StoreUpdateController,
          StoreFormState,
          StoreFormState,
          StoreFormState,
          Store
        > {
  StoreUpdateControllerFamily._()
    : super(
        retry: null,
        name: r'storeUpdateControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreUpdateControllerProvider call(Store store) =>
      StoreUpdateControllerProvider._(argument: store, from: this);

  @override
  String toString() => r'storeUpdateControllerProvider';
}

abstract class _$StoreUpdateController extends $Notifier<StoreFormState> {
  late final _$args = ref.$arg as Store;
  Store get store => _$args;

  StoreFormState build(Store store);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
