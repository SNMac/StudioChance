// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeDataSource)
final storeDataSourceProvider = StoreDataSourceProvider._();

final class StoreDataSourceProvider
    extends
        $FunctionalProvider<StoreDataSource, StoreDataSource, StoreDataSource>
    with $Provider<StoreDataSource> {
  StoreDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeDataSourceHash();

  @$internal
  @override
  $ProviderElement<StoreDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreDataSource create(Ref ref) {
    return storeDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreDataSource>(value),
    );
  }
}

String _$storeDataSourceHash() => r'8c0f5a73f456b1ce68cc14856612afe49414fec4';
