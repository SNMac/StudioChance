// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNotificationDataSource)
final localNotificationDataSourceProvider =
    LocalNotificationDataSourceProvider._();

final class LocalNotificationDataSourceProvider
    extends
        $FunctionalProvider<
          LocalNotificationDataSource,
          LocalNotificationDataSource,
          LocalNotificationDataSource
        >
    with $Provider<LocalNotificationDataSource> {
  LocalNotificationDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationDataSourceHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotificationDataSource create(Ref ref) {
    return localNotificationDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationDataSource>(value),
    );
  }
}

String _$localNotificationDataSourceHash() =>
    r'b032ed2ed7b338a278e60a580b6ea49c280b24d9';
