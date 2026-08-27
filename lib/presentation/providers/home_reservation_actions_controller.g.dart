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
    extends $AsyncNotifierProvider<HomeReservationActionsController, void> {
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
}

String _$homeReservationActionsControllerHash() =>
    r'cac3916d08624369967d2c94bff1429103ca294c';

abstract class _$HomeReservationActionsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
