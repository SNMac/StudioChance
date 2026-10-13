// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(holidayRepository)
final holidayRepositoryProvider = HolidayRepositoryProvider._();

final class HolidayRepositoryProvider
    extends
        $FunctionalProvider<
          HolidayRepository,
          HolidayRepository,
          HolidayRepository
        >
    with $Provider<HolidayRepository> {
  HolidayRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayRepositoryHash();

  @$internal
  @override
  $ProviderElement<HolidayRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HolidayRepository create(Ref ref) {
    return holidayRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayRepository>(value),
    );
  }
}

String _$holidayRepositoryHash() => r'9e2621f8c43772a3e43315ab3c4df8bdeab8f2e6';
