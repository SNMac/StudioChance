# 점포 필터 — 태스크

Last Updated: 2026-05-19

## Phase 1 — 상태 Provider 생성 (S) ✅

- [x] `lib/presentation/providers/home_store_filter_controller.dart` 생성
  - `@riverpod class HomeStoreFilterController` — `Set<String>` 반환
  - `build()`: `currentUserProvider` + `sharedPreferencesProvider` 에서 로드
    - 저장값 없으면 전체 선택 (첫 실행)
    - 저장된 deselectedIds 있으면 allIds - deselectedIds 반환
  - `toggle(String storeId)`: `Set<String>.of(state)` 방식으로 토글 후 `_persistDeselected()` 호출
  - `_persistDeselected()`: allIds - state = deselectedIds → `prefs.setStringList()` 저장
  - 코드 생성 완료 (`home_store_filter_controller.g.dart`)

## Phase 2 — 필터 모달 UI 구현 (M) ✅

- [x] `lib/presentation/home/widgets/store_filter_modal.dart` 생성
  - `StoreFilterModal extends ConsumerWidget`
  - `showStoreFilterModal(BuildContext context)` 함수
  - `DraggableScrollableSheet(initialChildSize: 0.5, snap: true, snapSizes: [0.5, 1.0])`
  - 각 항목: 도트(foregroundColor) + 점포명(Expanded) + 역할명(secondaryLabel) + checkmark(선택 시, systemBlue)

## Phase 3 — 예약 Provider 필터 적용 (S) ✅

- [x] `lib/presentation/providers/home_reservations_provider.dart` 수정
  - `homeStoreFilterControllerProvider` 구독
  - `storeIds = allIds.where((id) => selectedIds.contains(id))`
  - `storeIds.isEmpty` 이면 빈 리스트 반환

## Phase 4 — NavBar 버튼 연결 (S) ✅

- [x] `lib/presentation/home/widgets/home_nav_bar.dart` 수정
  - `import store_filter_modal.dart` 추가
  - `onPressed: () => showStoreFilterModal(context)` 연결
  - 플레이스홀더 `_showStoreFilter` 메서드 제거

## Phase 5 — 코드 생성 및 빌드 확인 (S) ✅

- [x] `dart run build_runner build --delete-conflicting-outputs` 성공
- [x] `dart analyze` — 에러 없음 확인

## 전체 완료 ✅
