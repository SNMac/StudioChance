// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeRepository)
final storeRepositoryProvider = StoreRepositoryProvider._();

final class StoreRepositoryProvider
    extends
        $FunctionalProvider<StoreRepository, StoreRepository, StoreRepository>
    with $Provider<StoreRepository> {
  StoreRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoreRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreRepository create(Ref ref) {
    return storeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreRepository>(value),
    );
  }
}

String _$storeRepositoryHash() => r'5a5f205f219c9b31ef8a41f78946c671bc92136d';
