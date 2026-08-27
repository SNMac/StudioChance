// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeDetail)
final storeDetailProvider = StoreDetailFamily._();

final class StoreDetailProvider
    extends $FunctionalProvider<AsyncValue<Store?>, Store?, FutureOr<Store?>>
    with $FutureModifier<Store?>, $FutureProvider<Store?> {
  StoreDetailProvider._({
    required StoreDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storeDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeDetailHash();

  @override
  String toString() {
    return r'storeDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Store?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Store?> create(Ref ref) {
    final argument = this.argument as String;
    return storeDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeDetailHash() => r'c73d22036602b6ae58d9d07e5eff8a398753afd3';

final class StoreDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Store?>, String> {
  StoreDetailFamily._()
    : super(
        retry: null,
        name: r'storeDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreDetailProvider call(String storeId) =>
      StoreDetailProvider._(argument: storeId, from: this);

  @override
  String toString() => r'storeDetailProvider';
}
