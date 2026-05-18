// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_reservation_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeReservationActionsController)
final homeReservationActionsControllerProvider =
    HomeReservationActionsControllerProvider._();

final class HomeReservationActionsControllerProvider
    extends $NotifierProvider<HomeReservationActionsController, void> {
  HomeReservationActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeReservationActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeReservationActionsControllerHash();

  @$internal
  @override
  HomeReservationActionsController create() =>
      HomeReservationActionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$homeReservationActionsControllerHash() =>
    r'45b6cd8ee5354e0adeec48a369bb9455f06bc1c7';

abstract class _$HomeReservationActionsController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
