# 점포 필터 구현 계획

Last Updated: 2026-05-19

## Executive Summary

`HomeNavBar`의 달력 아이콘 버튼을 눌렀을 때 점포 필터 모달을 표시한다.
각 항목은 **(색상 도트) (점포명) (역할)** 형태로 표시되며, 선택/해제 시 홈 캘린더의 예약 목록이 해당 점포만 필터링된다.
UI는 `ReservationListModal`과 동일한 패턴(`DraggableScrollableSheet` + `GroupedFormContainer`)을 사용한다.

---

## Current State Analysis

| 항목 | 현황 |
|------|------|
| **NavBar 버튼** | `HomeNavBar._showStoreFilter()` 구현됨 — `'점포 필터 (구현 예정)'` 플레이스홀더 |
| **예약 로딩** | `homeReservationsProvider`가 currentUser의 모든 storeIds를 구독 (필터 없음) |
| **필터 상태** | 없음 — 신규 Provider 필요 |
| **점포 정보** | `currentUserProvider` → `user.storeInfos: List<UserStoreInfo>` (id, name, role, color) |
| **색상 enum** | `StoreColor.foregroundColorValue` — 전경색 (실선 도트에 적합) |
| **역할 enum** | `UserRole.displayName` — '관리자', '스태프', '뷰어' |

### 참조 UI 패턴: `ReservationListModal`

```
ModalGrabber
ModalAppBar(title: '예약 목록')
SingleChildScrollView
  └─ GroupedFormContainer
       └─ CupertinoButton (height: inputFormComponentHeight)
            └─ Row
                 ├─ Container(8×8, circle, foregroundColor)  ← 색상 도트
                 ├─ SizedBox(width: 8)
                 ├─ Text(고객명·인원, bodyLarge, Expanded)
                 ├─ Text(시간범위, bodyLarge·normal·secondaryLabel)
                 └─ Icon(chevron_forward, tertiaryLabel)
```

점포 필터는 이 구조에서:
- 도트 색상 → `StoreColor.foregroundColorValue`
- 메인 텍스트 → `점포명` (Expanded)
- 우측 서브텍스트 → `역할명` (secondaryLabel)
- chevron 대신 → `checkmark` (선택된 점포) 또는 공백

---

## Proposed Future State

### 데이터 흐름

```
currentUserProvider (user.storeInfos)
        │
        ▼
HomeStoreFilterController (Set<String> selectedIds)
        │
        ├──▶ StoreFilterModal (ConsumerWidget) — 토글 UI
        │
        └──▶ homeReservationsProvider — 선택된 점포만 구독
```

### 상태 설계

```dart
// 선택된 점포 ID 집합 — 기본값: 모든 점포 선택
@riverpod
class HomeStoreFilterController extends _$HomeStoreFilterController {
  @override
  Set<String> build() {
    final user = ref.watch(currentUserProvider).asData?.value;
    if (user == null) return {};
    return user.storeInfos.map((e) => e.id).toSet();
  }

  void toggle(String storeId) { ... }
  bool get isAllSelected => ...
}
```

### 예약 필터링

```dart
// homeReservationsProvider — selectedIds로 storeIds 필터
final selectedIds = ref.watch(homeStoreFilterControllerProvider);
final storeIds = user.storeInfos
    .map((info) => info.id)
    .where((id) => selectedIds.contains(id))
    .toList();
```

### 모달 UI

```
ModalGrabber
ModalAppBar(title: '점포 선택')
SingleChildScrollView
  └─ GroupedFormContainer
       └─ for each storeInfo:
            CupertinoButton (inputFormComponentHeight)
              Row
                ├─ Container(8×8 dot, foregroundColor)
                ├─ SizedBox(8)
                ├─ Text(점포명, bodyLarge, Expanded)
                ├─ Text(역할명, bodyLarge·normal·secondaryLabel)
                ├─ SizedBox(12)
                └─ Icon(checkmark, systemBlue) or SizedBox(10) (미선택 시 공간 유지)
```

---

## Implementation Phases

### Phase 1 — 상태 Provider 생성 (S)
파일: `lib/presentation/providers/home_store_filter_controller.dart`

### Phase 2 — 필터 모달 UI 구현 (M)
파일: `lib/presentation/home/widgets/store_filter_modal.dart`

### Phase 3 — 예약 Provider 필터 적용 (S)
파일: `lib/presentation/providers/home_reservations_provider.dart` 수정

### Phase 4 — NavBar 버튼 연결 (S)
파일: `lib/presentation/home/widgets/home_nav_bar.dart` 수정

### Phase 5 — 코드 생성 및 빌드 확인 (S)
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Risk Assessment

| 위험 | 가능성 | 대응 |
|------|--------|------|
| `currentUserProvider` 로드 전 빈 Set | 낮음 | build()에서 `asData?.value` null-safe 처리 |
| 필터 해제로 빈 화면 | 보통 | 모든 해제 가능 (UX 결정: 허용) |
| `homeStoreFilterController` 재빌드 시 초기화 | 낮음 | `@riverpod` autoDispose — HomeScreen 살아있는 동안 유지됨 |

---

## Success Metrics

- [ ] 점포 필터 버튼 탭 → 모달 표시
- [ ] 각 항목에 (색상 도트) (점포명) (역할) 표시
- [ ] 항목 탭 → 선택/해제 (checkmark 토글)
- [ ] 해제된 점포의 예약이 캘린더에서 사라짐
- [ ] 모달 닫은 후 필터 상태 유지
- [ ] 코드 생성 후 빌드 성공
