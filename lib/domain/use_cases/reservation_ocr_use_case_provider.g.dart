// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_ocr_use_case_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reservationOcrUseCase)
final reservationOcrUseCaseProvider = ReservationOcrUseCaseProvider._();

final class ReservationOcrUseCaseProvider
    extends
        $FunctionalProvider<
          ReservationOcrUseCase,
          ReservationOcrUseCase,
          ReservationOcrUseCase
        >
    with $Provider<ReservationOcrUseCase> {
  ReservationOcrUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationOcrUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationOcrUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReservationOcrUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReservationOcrUseCase create(Ref ref) {
    return reservationOcrUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReservationOcrUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReservationOcrUseCase>(value),
    );
  }
}

String _$reservationOcrUseCaseHash() =>
    r'5e7f24781b44d189c6107f6602c0f5d030169449';
