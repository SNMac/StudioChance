// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeUseCase)
final storeUseCaseProvider = StoreUseCaseProvider._();

final class StoreUseCaseProvider
    extends $FunctionalProvider<StoreUseCase, StoreUseCase, StoreUseCase>
    with $Provider<StoreUseCase> {
  StoreUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeUseCaseHash();

  @$internal
  @override
  $ProviderElement<StoreUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreUseCase create(Ref ref) {
    return storeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreUseCase>(value),
    );
  }
}

String _$storeUseCaseHash() => r'a34e50b47f26acbca35afcb05b16ad745a22ffb6';
