// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serverClockRepository)
final serverClockRepositoryProvider = ServerClockRepositoryProvider._();

final class ServerClockRepositoryProvider
    extends
        $FunctionalProvider<
          ServerClockRepository,
          ServerClockRepository,
          ServerClockRepository
        >
    with $Provider<ServerClockRepository> {
  ServerClockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServerClockRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerClockRepository create(Ref ref) {
    return serverClockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerClockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerClockRepository>(value),
    );
  }
}

String _$serverClockRepositoryHash() =>
    r'9c83d560329ff4baef2454e74f7efb3f870dd4c8';
