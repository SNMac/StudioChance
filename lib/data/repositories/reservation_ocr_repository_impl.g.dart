// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_ocr_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reservationOcrRepository)
final reservationOcrRepositoryProvider = ReservationOcrRepositoryProvider._();

final class ReservationOcrRepositoryProvider
    extends
        $FunctionalProvider<
          ReservationOcrRepository,
          ReservationOcrRepository,
          ReservationOcrRepository
        >
    with $Provider<ReservationOcrRepository> {
  ReservationOcrRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationOcrRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationOcrRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReservationOcrRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReservationOcrRepository create(Ref ref) {
    return reservationOcrRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReservationOcrRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReservationOcrRepository>(value),
    );
  }
}

String _$reservationOcrRepositoryHash() =>
    r'caf199b07d36c3234698f3e33777c6b4b3a97d4f';
