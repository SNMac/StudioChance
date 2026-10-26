// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gemini_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geminiDataSource)
final geminiDataSourceProvider = GeminiDataSourceProvider._();

final class GeminiDataSourceProvider
    extends
        $FunctionalProvider<
          GeminiDataSource,
          GeminiDataSource,
          GeminiDataSource
        >
    with $Provider<GeminiDataSource> {
  GeminiDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiDataSourceHash();

  @$internal
  @override
  $ProviderElement<GeminiDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeminiDataSource create(Ref ref) {
    return geminiDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeminiDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeminiDataSource>(value),
    );
  }
}

String _$geminiDataSourceHash() => r'49b5781077b7f1913353027bbcee8480893fb071';
