// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationUseCase)
final notificationUseCaseProvider = NotificationUseCaseProvider._();

final class NotificationUseCaseProvider
    extends
        $FunctionalProvider<
          NotificationUseCase,
          NotificationUseCase,
          NotificationUseCase
        >
    with $Provider<NotificationUseCase> {
  NotificationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<NotificationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationUseCase create(Ref ref) {
    return notificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationUseCase>(value),
    );
  }
}

String _$notificationUseCaseHash() =>
    r'4601256b3ce1958ae9b7f05f3d49f24731d86656';
