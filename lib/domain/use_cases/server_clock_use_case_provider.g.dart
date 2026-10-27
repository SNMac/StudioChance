// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_clock_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(serverClockUseCase)
final serverClockUseCaseProvider = ServerClockUseCaseProvider._();

final class ServerClockUseCaseProvider
    extends
        $FunctionalProvider<
          ServerClockUseCase,
          ServerClockUseCase,
          ServerClockUseCase
        >
    with $Provider<ServerClockUseCase> {
  ServerClockUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverClockUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverClockUseCaseHash();

  @$internal
  @override
  $ProviderElement<ServerClockUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerClockUseCase create(Ref ref) {
    return serverClockUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerClockUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerClockUseCase>(value),
    );
  }
}

String _$serverClockUseCaseHash() =>
    r'06af2a2c9104f3215b7ef0cc0f19c95fb6df9ea0';
