// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈 캘린더에서 표시할 점포 ID 집합.
///
/// - 기본값: 모든 점포 선택
/// - SharedPreferences에 deselected IDs를 저장하여 앱 재시작 후에도 유지
/// - 새로 추가된 점포는 자동으로 선택 상태 (deselected 목록에 없으므로)

@ProviderFor(HomeStoreFilterController)
final homeStoreFilterControllerProvider = HomeStoreFilterControllerProvider._();

/// 홈 캘린더에서 표시할 점포 ID 집합.
///
/// - 기본값: 모든 점포 선택
/// - SharedPreferences에 deselected IDs를 저장하여 앱 재시작 후에도 유지
/// - 새로 추가된 점포는 자동으로 선택 상태 (deselected 목록에 없으므로)
final class HomeStoreFilterControllerProvider
    extends $NotifierProvider<HomeStoreFilterController, Set<String>> {
  /// 홈 캘린더에서 표시할 점포 ID 집합.
  ///
  /// - 기본값: 모든 점포 선택
  /// - SharedPreferences에 deselected IDs를 저장하여 앱 재시작 후에도 유지
  /// - 새로 추가된 점포는 자동으로 선택 상태 (deselected 목록에 없으므로)
  HomeStoreFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeStoreFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeStoreFilterControllerHash();

  @$internal
  @override
  HomeStoreFilterController create() => HomeStoreFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$homeStoreFilterControllerHash() =>
    r'b2d4a47cb32670ed2dca66eb87fb7a5e8d4b7cd4';

/// 홈 캘린더에서 표시할 점포 ID 집합.
///
/// - 기본값: 모든 점포 선택
/// - SharedPreferences에 deselected IDs를 저장하여 앱 재시작 후에도 유지
/// - 새로 추가된 점포는 자동으로 선택 상태 (deselected 목록에 없으므로)

abstract class _$HomeStoreFilterController extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
