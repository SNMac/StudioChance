# Phase 9: 캘린더 셀 탭 인터랙션 설계

Date: 2026-03-28
Branch: feat/#5-home

---

## 개요

3일 캘린더의 예약 셀 탭 인터랙션을 구현한다.
- 일반 셀 탭: z-순서 최상단 이동 + 하이라이트 + 상세 모달 (하프 시트)
- N≥4 그룹 셀 탭: 이벤트 목록 모달 → 선택 → 하이라이트 + 상세 모달
- `isContinuation` 셀 탭: 원본 날짜로 이동 + 원본 셀 하이라이트 + 상세 모달
- 오버플로우 셀(`OverflowCell`) 제거, N에 관계없이 항상 스택 표시

**상세 모달은 하프 시트로 시작** — 캘린더 셀이 뒤에 보이므로 하이라이트가 항상 필요.
위로 끌어올리면 전체 화면으로 확장.

---

## 섹션 1: 데이터 모델 변경

### ReservationDisplayData 재구성

기존의 중복 필드를 제거하고 `ReservationSummary`를 내장한다.

```dart
class ReservationDisplayData {
  final ReservationSummary summary;
  final bool isContinuation;
  final bool continuesNextDay;
}
```

**제거 대상 (ReservationDisplayData 기존 필드):**
- `reserverName`, `headcount`, `phoneNumber` → `summary.customerName`, `summary.headCount`, `summary.customerPhone`
- `status` (셀 전용 enum) → `summary.status` (도메인 `ReservationStatus`)
- `colorTheme` (`ReservationCellColorTheme`) → `summary.storeSummary.color` (`StoreColor`)
- `isAllDay` → `summary.isAllDay`
- `date` → `summary.startTime` (종일/시간대 모두 startTime으로 식별)

**제거 대상 (클래스/enum):**
- `ReservationCellColorTheme` — `StoreColor`와 완전 중복 (background/foreground/labelColorValue 동일)
- `ReservationStatus` (reservation_cell.dart 내 enum) — 도메인 enum과 이름 충돌, 제거

**split 시 copyWith 활용 (`three_day_calendar.dart` `_eventsForDate`):**
- `continuesNextDay=true`: `summary.copyWith(endTime: midnight)`
- `isContinuation=true`: `summary.copyWith(startTime: dateStart)`

### ReservationCell 색상/상태 매핑 변경

| 변경 전 | 변경 후 |
|---------|---------|
| `data.colorTheme.backgroundColor` | `Color(data.summary.storeSummary.color.backgroundColorValue)` |
| `data.colorTheme.foregroundColor` | `Color(data.summary.storeSummary.color.foregroundColorValue)` |
| `data.colorTheme.labelColor` | `Color(data.summary.storeSummary.color.labelColorValue)` |
| `data.status` (셀 enum) | `data.summary.status` (도메인 enum) |

`_StatusIcon` SVG 매핑도 도메인 `ReservationStatus`(`pending`, `confirmed`, `canceled`)로 변경.

### 목업 Reservation 맵

`three_day_calendar.dart`에 기존 mock events와 1:1 대응하는 `Map<String, Reservation>` 추가.
`TimeGrid`에 `Map<String, Reservation> reservations` 파라미터로 전달하여 탭 시 조회.

---

## 섹션 2: 스택 레이아웃 알고리즘 변경

### OverflowCell 제거

- `cellWidth < 31px → OverflowCell` 임계값 **제거**
- N에 관계없이 항상 스택으로 표시
- `overflow_cell.dart` 삭제
- `_PositionedItem.overflow` 생성자 삭제

### _PositionedItem 변경

```dart
class _PositionedItem {
  final ReservationDisplayData event;
  final double left;
  final double right;
  final bool clipContent;
  /// N≥4 그룹: non-null이면 탭 시 목록 모달 표시
  final List<ReservationDisplayData>? groupEvents;
}
```

### stagger 규칙 (변경 없음, 임계값만 제거)

| N | stagger |
|---|---------|
| N=2, delta==0 | `usableWidth/2` |
| N=2, delta>0 | `8px` 고정 |
| N≥3 | `usableWidth/N` |

`_computePositions`에서 N≥4 컴포넌트는 `groupEvents = compEvents`로 채워 `_PositionedItem` 생성.

---

## 섹션 3: 탭 인터랙션

### TimeGrid 전환

`TimeGrid`: `ConsumerWidget` → `ConsumerStatefulWidget`

```dart
String? _selectedId;    // z-순서 최상단 셀 id
String? _highlightedId; // 하이라이트 중인 셀 id (로컬)
```

하이라이트 적용 시 effective id:
```dart
final externalHighlight = ref.watch(pendingHighlightIdProvider);
final effectiveHighlightId = _highlightedId ?? externalHighlight;
```

### 빌드 시 z-순서 처리

`_selectedId`와 일치하는 `_PositionedItem`을 목록 맨 마지막(=맨 앞 z-순서)으로 이동하여 `Stack`에 배치.

### 하이라이트 상태 (ReservationCell 변경)

`ReservationCell`에 `bool isHighlighted` 파라미터 추가.

`isHighlighted == true` 일 때:
- 배경 전체: `foregroundColor`
- 좌측 스트립: `foregroundColor` (배경과 동일, 시각적으로 단일 색)
- 라벨(텍스트·아이콘): `white`

### 신규 Provider (home_calendar_controller.dart)

**ScrollToTimeTrigger** — `ScrollToCurrentTimeTrigger`와 동일한 패턴:

```dart
@riverpod
class ScrollToTimeTrigger extends _$ScrollToTimeTrigger {
  @override
  DateTime? build() => null;
  void trigger(DateTime time) => state = time;
  void clear() => state = null;
}
```

`ThreeDayCalendar`: `ref.listen(scrollToTimeTriggerProvider)`로 감지,
페이지 이동 완료(`animateToPage.then()`) 후 해당 시간 offset으로 `_syncAllScrollControllers` 호출.

**PendingHighlightId** — isContinuation 탭 시 cross-widget 하이라이트용:

```dart
@riverpod
class PendingHighlightId extends _$PendingHighlightId {
  @override
  String? build() => null;
  void set(String id) => state = id;
  void clear() => state = null;
}
```

각 `TimeGrid`는 `ref.watch(pendingHighlightIdProvider)`로 감지하여 `effectiveHighlightId`에 반영.

**HomeCalendarController 신규 메서드:**

```dart
void selectDateFromContinuation(DateTime date) {
  _threeDayTransition = CalendarTransitionKind.animate;
  _monthlyTransition = CalendarTransitionKind.animate;
  selectDate(date);
}
```

### 탭 흐름별 동작

**① 일반 셀 탭 (N<4, groupEvents == null):**
```
1. _highlightedId = event.id, _selectedId = event.id
2. setState → 해당 셀 하이라이트 + z-순서 최상단
3. await showReservationDetailModal(reservations[event.id])
4. _highlightedId = null, _selectedId = null
```

**② N≥4 그룹 셀 탭 (groupEvents != null):**
```
1. await showReservationListModal(groupEvents) → ReservationSummary? selected
2. selected == null → 취소, 종료
3. _highlightedId = selected.id, _selectedId = selected.id
4. setState → 선택된 셀 하이라이트 + z-순서 최상단
5. await showReservationDetailModal(reservations[selected.id])
6. _highlightedId = null, _selectedId = null
```

**③ isContinuation 셀 탭:**
```
1. originalStartTime = reservations[event.id].startTime
2. originalDate = DateTime(originalStartTime.year, originalStartTime.month, originalStartTime.day)
3. ref.read(pendingHighlightIdProvider.notifier).set(event.id)
   → 원본 날짜 TimeGrid가 해당 셀을 하이라이트
4. ref.read(homeCalendarControllerProvider.notifier).selectDateFromContinuation(originalDate)
   → selectedStartDate = originalDate (animate 전환)
5. ref.read(scrollToTimeTriggerProvider.notifier).trigger(originalStartTime)
   → ThreeDayCalendar가 페이지 이동 완료 후 해당 시간대로 수직 스크롤
6. await showReservationDetailModal(reservations[event.id])
7. ref.read(pendingHighlightIdProvider.notifier).clear()
```

---

## 섹션 4: 모달 구조

### 파일 위치

```
lib/presentation/home/widgets/three_day_calendar/
  reservation_detail_modal.dart   (신규)
  reservation_list_modal.dart     (신규)
```

### ReservationDetailModal (플레이스홀더 + 하프 시트)

`Reservation` 객체를 받아 고객명만 표시하는 플레이스홀더.
실제 구현 시 예약 수정 편집 폼 (예약 점포, 예약 상태, 예약자명, 인원, 연락처, 메모,
하루종일, 입실/퇴실 일시, 플랫폼, 결제 방식, 요금, 추가 요금/할인) — 별도 Phase에서 구현.

**하프 시트 동작:**
- 초기: 화면 절반. 캘린더가 뒤에 보임 → 셀 하이라이트 필요
- 위로 드래그: **시트가 전체 화면을 덮음** (모달 상태 유지, 네비게이션 push 아님)
  - 드래그 핸들(pill)이 상단에 유지됨
  - 아래로 드래그하면 다시 하프 시트로 복귀 또는 닫힘

```dart
// iOS: detents 활용
showCupertinoSheet<void>(
  context: context,
  detents: [SheetDetent.medium, SheetDetent.large],
  builder: (_) => ReservationDetailModal(reservation: r),
)

// Android: DraggableScrollableSheet
showModalBottomSheet<void>(
  isScrollControlled: true,
  useSafeArea: true,
  context: context,
  builder: (_) => DraggableScrollableSheet(
    initialChildSize: 0.5,
    minChildSize: 0.5,
    maxChildSize: 1.0,
    expand: false,
    builder: (_, controller) => ReservationDetailModal(reservation: r, scrollController: controller),
  ),
)
```

### ReservationListModal

N≥4 그룹의 이벤트 목록. 선택된 `ReservationSummary`를 반환.
목록 모달은 하프 시트 불필요 — 고정 크기 (콘텐츠에 맞게 자동).

- `GroupedFormContainer` + `TitleNavigationButton` 스타일 아이템
- 아이템 구성: 색상 도트(StoreColor.foregroundColorValue, 8×8 circle) + 고객명 왼쪽, 시간(HH:mm~HH:mm) 오른쪽, chevron
- 탭 → `Navigator.pop(context, selectedSummary)`

```dart
// iOS
final selected = await showCupertinoSheet<ReservationSummary>(
  context: context,
  builder: (_) => ReservationListModal(events: groupEvents),
)

// Android
final selected = await showModalBottomSheet<ReservationSummary>(
  isScrollControlled: true,
  useSafeArea: true,
  context: context,
  builder: (_) => ReservationListModal(events: groupEvents),
)
```

---

## 수정 대상 파일 요약

| 파일 | 변경 유형 |
|------|---------|
| `reservation_cell.dart` | `ReservationDisplayData` 재구성, `ReservationCellColorTheme` 제거, 셀 `ReservationStatus` enum 제거, `isHighlighted` 파라미터 추가 |
| `time_grid.dart` | `ConsumerStatefulWidget` 전환, `_PositionedItem` 변경, stagger 임계값 제거, 탭 핸들러 추가, `reservations` 파라미터 추가, `pendingHighlightIdProvider` watch 추가 |
| `three_day_calendar.dart` | `ReservationDisplayData` 생성 로직 수정, mock `Reservation` 맵 추가, `TimeGrid`에 `reservations` 전달, `scrollToTimeTrigger` listen 추가 |
| `all_day_row.dart` | `ReservationDisplayData` 필드 접근 수정 |
| `home_calendar_controller.dart` | `ScrollToTimeTrigger` provider 추가, `PendingHighlightId` provider 추가, `selectDateFromContinuation()` 메서드 추가 |
| `overflow_cell.dart` | **삭제** |
| `reservation_detail_modal.dart` | **신규** |
| `reservation_list_modal.dart` | **신규** |

---

## 스코프 아웃 (추후)

- `ReservationDetailModal` 실제 디자인 구현
- 실제 Firestore 데이터 연결 (mock 제거)
- build_runner 불필요 — 코드 생성 없음
