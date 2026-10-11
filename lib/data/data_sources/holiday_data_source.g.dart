// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(holidayDataSource)
final holidayDataSourceProvider = HolidayDataSourceProvider._();

final class HolidayDataSourceProvider
    extends
        $FunctionalProvider<
          HolidayDataSource,
          HolidayDataSource,
          HolidayDataSource
        >
    with $Provider<HolidayDataSource> {
  HolidayDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'holidayDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$holidayDataSourceHash();

  @$internal
  @override
  $ProviderElement<HolidayDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HolidayDataSource create(Ref ref) {
    return holidayDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HolidayDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HolidayDataSource>(value),
    );
  }
}

String _$holidayDataSourceHash() => r'8db1d6bda6554e21ae88b836b766fb823954e47b';
