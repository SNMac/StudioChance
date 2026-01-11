// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_input_form_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoreInputFormViewModel)
final storeInputFormViewModelProvider = StoreInputFormViewModelFamily._();

final class StoreInputFormViewModelProvider
    extends $NotifierProvider<StoreInputFormViewModel, StoreInputFormState> {
  StoreInputFormViewModelProvider._({
    required StoreInputFormViewModelFamily super.from,
    required Store? super.argument,
  }) : super(
         retry: null,
         name: r'storeInputFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeInputFormViewModelHash();

  @override
  String toString() {
    return r'storeInputFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StoreInputFormViewModel create() => StoreInputFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreInputFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreInputFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StoreInputFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeInputFormViewModelHash() =>
    r'ebf57ca9f9f4833f29db74282f64aecd501e4ef6';

final class StoreInputFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          StoreInputFormViewModel,
          StoreInputFormState,
          StoreInputFormState,
          StoreInputFormState,
          Store?
        > {
  StoreInputFormViewModelFamily._()
    : super(
        retry: null,
        name: r'storeInputFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreInputFormViewModelProvider call(Store? initialStore) =>
      StoreInputFormViewModelProvider._(argument: initialStore, from: this);

  @override
  String toString() => r'storeInputFormViewModelProvider';
}

abstract class _$StoreInputFormViewModel
    extends $Notifier<StoreInputFormState> {
  late final _$args = ref.$arg as Store?;
  Store? get initialStore => _$args;

  StoreInputFormState build(Store? initialStore);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StoreInputFormState, StoreInputFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoreInputFormState, StoreInputFormState>,
              StoreInputFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
