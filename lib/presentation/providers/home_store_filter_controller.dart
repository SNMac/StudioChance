import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/hour_height_preference_provider.dart';

part 'home_store_filter_controller.g.dart';

const _kDeselectedStoreIdsKey = 'home_store_filter_deselected_ids';

/// 홈 캘린더에서 표시할 점포 ID 집합.
///
/// - 기본값: 모든 점포 선택
/// - SharedPreferences에 deselected IDs를 저장하여 앱 재시작 후에도 유지
/// - 새로 추가된 점포는 자동으로 선택 상태 (deselected 목록에 없으므로)
@riverpod
class HomeStoreFilterController extends _$HomeStoreFilterController {
  @override
  Set<String> build() {
    final user = ref.watch(currentUserProvider).asData?.value;
    if (user == null) return {};

    final allIds = user.storeInfos.map((info) => info.id).toSet();
    final prefs = ref.watch(sharedPreferencesProvider).asData?.value;

    // prefs 로드 전이거나 저장값 없으면 전체 선택
    if (prefs == null) return Set<String>.of(allIds);

    final saved = prefs.getStringList(_kDeselectedStoreIdsKey);
    if (saved == null) return Set<String>.of(allIds);

    final deselectedIds = saved.toSet();
    return allIds.difference(deselectedIds);
  }

  /// 점포 선택/해제 토글 후 변경사항을 SharedPreferences에 저장.
  void toggle(String storeId) {
    final mutable = Set<String>.of(state);
    if (state.contains(storeId)) {
      mutable.remove(storeId);
    } else {
      mutable.add(storeId);
    }
    state = mutable;
    _persistDeselected();
  }

  /// 전체 선택 상태이면 전체 해제, 아니면 전체 선택.
  void toggleAll() {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;
    final allIds = user.storeInfos.map((info) => info.id).toSet();
    final isAllSelected =
        state.length == allIds.length && state.containsAll(allIds);
    state = isAllSelected ? {} : Set<String>.of(allIds);
    _persistDeselected();
  }

  /// 특정 점포를 표시 상태로 만든다 (푸시 알림 딥링크 등에서 사용).
  ///
  /// 이미 선택돼 있으면 아무것도 하지 않으며, 다른 점포의 선택 상태는 유지한다.
  void ensureSelected(String storeId) {
    if (state.contains(storeId)) return;
    state = {...state, storeId};
    _persistDeselected();
  }

  /// 현재 상태 기준으로 deselected IDs를 계산하여 SharedPreferences에 저장.
  Future<void> _persistDeselected() async {
    final prefs = ref.read(sharedPreferencesProvider).asData?.value;
    if (prefs == null) return;

    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    final allIds = user.storeInfos.map((info) => info.id).toSet();
    final deselectedIds = allIds.difference(state).toList();
    await prefs.setStringList(_kDeselectedStoreIdsKey, deselectedIds);
  }
}
