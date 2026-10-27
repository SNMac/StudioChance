// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serverClockDataSource)
final serverClockDataSourceProvider = ServerClockDataSourceProvider._();

final class ServerClockDataSourceProvider
    extends
        $FunctionalProvider<
          ServerClockDataSource,
          ServerClockDataSource,
          ServerClockDataSource
        >
    with $Provider<ServerClockDataSource> {
  ServerClockDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockDataSourceHash();

  @$internal
  @override
  $ProviderElement<ServerClockDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerClockDataSource create(Ref ref) {
    return serverClockDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerClockDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerClockDataSource>(value),
    );
  }
}

String _$serverClockDataSourceHash() =>
    r'0d4cac2ad47a994e944767a7fea8608d69b1512e';
