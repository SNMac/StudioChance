// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reservationDataSource)
final reservationDataSourceProvider = ReservationDataSourceProvider._();

final class ReservationDataSourceProvider
    extends
        $FunctionalProvider<
          ReservationDataSource,
          ReservationDataSource,
          ReservationDataSource
        >
    with $Provider<ReservationDataSource> {
  ReservationDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationDataSourceHash();

  @$internal
  @override
  $ProviderElement<ReservationDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReservationDataSource create(Ref ref) {
    return reservationDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReservationDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReservationDataSource>(value),
    );
  }
}

String _$reservationDataSourceHash() =>
    r'de3107371fd8bec6070338bb60f72fecfefa35cf';
