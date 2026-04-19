// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reservationUseCase)
final reservationUseCaseProvider = ReservationUseCaseProvider._();

final class ReservationUseCaseProvider
    extends
        $FunctionalProvider<
          ReservationUseCase,
          ReservationUseCase,
          ReservationUseCase
        >
    with $Provider<ReservationUseCase> {
  ReservationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReservationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReservationUseCase create(Ref ref) {
    return reservationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReservationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReservationUseCase>(value),
    );
  }
}

String _$reservationUseCaseHash() =>
    r'83f65066bd9b6ed981c4372d113b3f70debe6683';
