// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteConfig)
final remoteConfigProvider = RemoteConfigProvider._();

final class RemoteConfigProvider
    extends
        $FunctionalProvider<
          FirebaseRemoteConfig,
          FirebaseRemoteConfig,
          FirebaseRemoteConfig
        >
    with $Provider<FirebaseRemoteConfig> {
  RemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigHash();

  @$internal
  @override
  $ProviderElement<FirebaseRemoteConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseRemoteConfig create(Ref ref) {
    return remoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseRemoteConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseRemoteConfig>(value),
    );
  }
}

String _$remoteConfigHash() => r'ce871615b5745cd4b6ee91e29ef3947f660eca45';
