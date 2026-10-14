// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 점포 수정 화면 진입 — 마이페이지와 예약 계산 내역 시트가 공유한다

@ProviderFor(StoreEditController)
final storeEditControllerProvider = StoreEditControllerProvider._();

/// 점포 수정 화면 진입 — 마이페이지와 예약 계산 내역 시트가 공유한다
final class StoreEditControllerProvider
    extends $AsyncNotifierProvider<StoreEditController, void> {
  /// 점포 수정 화면 진입 — 마이페이지와 예약 계산 내역 시트가 공유한다
  StoreEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeEditControllerHash();

  @$internal
  @override
  StoreEditController create() => StoreEditController();
}

String _$storeEditControllerHash() =>
    r'c1f336e3903d5ff476105e49bd1850e4ce3ab529';

/// 점포 수정 화면 진입 — 마이페이지와 예약 계산 내역 시트가 공유한다

abstract class _$StoreEditController extends $AsyncNotifier<void> {
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
