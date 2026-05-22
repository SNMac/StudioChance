// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_ocr_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReservationOcrController)
final reservationOcrControllerProvider = ReservationOcrControllerProvider._();

final class ReservationOcrControllerProvider
    extends
        $AsyncNotifierProvider<
          ReservationOcrController,
          ReservationOcrResult?
        > {
  ReservationOcrControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationOcrControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationOcrControllerHash();

  @$internal
  @override
  ReservationOcrController create() => ReservationOcrController();
}

String _$reservationOcrControllerHash() =>
    r'dc9c87b84aae082771a8af939e17b349789b7880';

abstract class _$ReservationOcrController
    extends $AsyncNotifier<ReservationOcrResult?> {
  FutureOr<ReservationOcrResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ReservationOcrResult?>, ReservationOcrResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ReservationOcrResult?>,
                ReservationOcrResult?
              >,
              AsyncValue<ReservationOcrResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
