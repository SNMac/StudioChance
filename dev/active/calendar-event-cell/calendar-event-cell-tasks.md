# 캘린더 일정 셀 - 작업 체크리스트

Last Updated: 2026-04-01 (Phase 22 완료 — 리스트 모달 chevron 크기 수정)

---

## Phase 1~6: 구현 완료 ✅

---

## Phase 1: 색상 상수 추가 ✅

**파일:** `lib/presentation/colors.dart`

- [x] **1-1**: Background 색상 7개 추가 (redBackground ~ purpleBackground)
- [x] **1-2**: Foreground 색상 7개 추가 (redForeground ~ purpleForeground)
- [x] **1-3**: Label 색상 7개 추가 (redLabel ~ purpleLabel)

---

## Phase 2: 줌 범위 수정 ✅

**파일:** `lib/constants/ui_constants.dart`, `lib/presentation/providers/hour_height_preference_provider.dart`

- [x] **2-1**: `defaultHourHeight` 36.0 → 40.0, `minHourHeight` 18.0 → 36.0 변경
- [x] **2-2**: `loadHourHeight`에 `.clamp(minHourHeight, maxHourHeight)` 추가

---

## Phase 3: ReservationCell 위젯 구현 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart` (신규)

- [x] **3-1**: `ReservationStatus` enum (confirmed, pendingPayment, cancelled)
- [x] **3-2**: `ReservationCellColorTheme` enum (7색, 3개 getter)
- [x] **3-3**: `ReservationDisplayData` 클래스 (date 필드 포함)
- [x] **3-4**: `_StatusIcon` widget (SVG 3종, colorFilter)
- [x] **3-5**: `ReservationCell` widget + `clipContent` 파라미터

---

## Phase 4: AllDayCell 수정 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

- [x] **4-1~4-4**: events 파라미터, Positioned(left:1, right:8, top:1, bottom:4) 배치

---

## Phase 5: TimeGrid 수정 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

- [x] **5-1~5-4**: events 파라미터, _topOffset/_cellHeight 계산, Positioned 배치
  - 위 구분선 간격: +0.5px, 아래 구분선 간격: −1.5px
  - `_cellHeight = hourHeight * duration / 60 - 2.0` (clamp 1.0 이상)

---

## Phase 6: ThreeDayCalendar 목업 데이터 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

- [x] **6-1**: `_buildMockEvents()` 오늘 기준 이벤트
- [x] **6-2**: `_eventsForDate()` 날짜 필터링
- [x] **6-3~6-4**: AllDayCell, TimeGrid에 연결

---

## 버그 수정 ✅

- [x] **Fix-1**: 셀 색상 반전 수정 (스트립↔배경 교체)
- [x] **Fix-2**: 아이콘 간격 SizedBox(4)→SizedBox(8)
- [x] **Fix-3**: 아이콘 12→10, top:4, right:4, FittedBox, 세로 중앙 정렬
- [x] **Fix-4**: minHourHeight 40→36, Padding(bottom:4) 롤백
- [x] **Fix-5**: Padding top:4→1.5 (셀 상단~아이콘 4px 유지하면서 하단 여백 개선)

---

## Phase 7: 이벤트 겹침 레이아웃 (2개 기준) ✅

**파일:** `time_grid.dart`, `reservation_cell.dart`, `three_day_calendar.dart`

- [x] **7-1**: `_PositionedEvent` 클래스 (event, left, right, clipContent)
- [x] **7-2**: `_computePositions()` — z 순서 정렬 + 열 배정 (고정 left=52 방식)
  - 열 0 → 전체 너비 (clipContent=false)
  - 열 1+ → left=52 (clipContent=true)
- [x] **7-3**: `ReservationCell.clipContent` 파라미터
- [x] **7-4**: 목업 데이터에 오늘 10:00-14:00 노랑 이벤트 추가

> ⚠️ Phase 7은 임시 구현 (고정 left=52). Phase 8에서 균등 분할로 교체 예정.

---

## Phase 8: 스택 레이아웃 + delta 기반 stagger + 오버플로우 셀 ✅

**파일:** `time_grid.dart` (전면 교체), `overflow_cell.dart` (신규), `reservation_cell.dart` (clipContent 복원), `three_day_calendar.dart`

- [x] **8-1**: `overflow_cell.dart` 신규 생성
  - `OverflowCell` 위젯 (events: List<ReservationDisplayData>)
  - 배경: `context.tertiarySystemFill` (임시, 사용자 결정 대기)
  - 좌측 4px 멀티컬러 스트립 (각 이벤트의 foregroundColor 균등 분할)
  - 외곽선: 0.5px systemBackground
  - 내용: "N개" 텍스트 (secondaryLabel 색상)
- [x] **8-2**: `time_grid.dart` 스택 알고리즘 구현
  - `_minCellWidthFor1Char = 31.0`, `_differentStartStagger = 8.0`, `_bounceExtension = 1000.0` 상수
  - `_PositionedItem` (normal/overflow 분기, clipContent 포함)
  - `_computePositions(events, columnWidth)`:
    - 그리디 인터벌 컬러링 → 열 배정
    - Union-Find → 연결 컴포넌트 묶기
    - N = max(col)+1, cellWidth = usableWidth/N
    - **N=2 전용 Step 5a**: delta == 0 → cellWidth stagger, delta > 0 → 8px stagger
    - cellWidth < 31 → OverflowCell
    - **스택 배치**: left = 1.0 + col × stagger, right = 8.0 (고정)
    - clipContent = col > 0
  - `_placementFor()`: isContinuation→topGap=0·위로 1000px 연장, continuesNextDay→bottomGap=0·아래로 1000px 연장
  - `LayoutBuilder` → columnWidth 획득
- [x] **8-3**: `reservation_cell.dart` clipContent 파라미터 복원
  - clipContent=false: FittedBox scaleDown (back 셀, 단독 셀)
  - clipContent=true: 단일행 TextOverflow.clip (front/middle 셀)
- [x] **8-4**: 목업 데이터 전체 시나리오 커버
  - 오늘: 단독 + N=4 오버플로우
  - 내일: N=2 delta=0, N=3 delta=0, N=2 delta=20분, N=2 delta=30분
  - 모레: 단독들 + N=2 delta=60분 (4px gap)
- [ ] **8-5**: OverflowCell 배경 색상 확정 (사용자 결정 대기, 현재 `tertiarySystemFill` 임시)
  > Phase 8 구현은 완료. 이 항목은 디자인 결정 사항으로 Phase 9 이후 처리.
- [x] **8-6**: N=2 stagger 임계값 수정 — `delta ≤ 30` → `delta == 0`
  - delta=0 (동시 시작)만 cellWidth stagger, delta>0은 모두 8px 고정
- [x] **8-7**: 자정 넘김 이벤트 처리
  - `ReservationDisplayData.isContinuation` / `continuesNextDay` 필드 추가
  - `ReservationCell`: isContinuation=true 시 배경+스트립만 렌더링
  - `ReservationCell`: isContinuation/continuesNextDay에 따라 코너 반경 조건부 적용
  - `time_grid.dart`: `_placementFor()` — isContinuation→topGap=0, continuesNextDay→bottomGap=0
  - `time_grid.dart`: `_bounceExtension=1000px` — Stack(Clip.none) 이용해 바운스 시 연결
    - isContinuation: top을 위로 1000px 연장 (top 바운스 시 연속으로 보임)
    - continuesNextDay: height를 아래로 1000px 연장 (bottom 바운스 시 연속으로 보임)
  - `_eventsForDate`: 자정 넘김 이벤트 분할 (시작일 continuesNextDay=true + 익일 isContinuation=true)
  - 목업 데이터: 오늘 22:00 ~ 내일 02:00 (이도윤, indigo, confirmed) 추가

---

## Phase 9: 셀 탭 인터랙션 ✅ (완료 — 모달 UI 후속 수정 필요)

**파일:** `time_grid.dart`, `reservation_detail_modal.dart`, `reservation_list_modal.dart`, `home_calendar_controller.dart`

### 9-0: home_calendar_controller.dart 신규 Provider + 메서드
- [x] `ScrollToTimeTrigger` provider 추가
- [x] `PendingHighlightId` provider 추가
- [x] `selectDateFromContinuation()` 메서드 추가

### 9-1: reservation_cell.dart — ReservationDisplayData 재구성
- [x] `ReservationSummary` 내장 구조로 재구성
- [x] `ReservationCellColorTheme`, 셀 `ReservationStatus` enum 제거
- [x] `isHighlighted` 파라미터 추가 (foreground 색 배경 + white 텍스트)

### 9-2: OverflowCell 제거 + TimeGrid ConsumerStatefulWidget 전환
- [x] `overflow_cell.dart` 삭제
- [x] `_PositionedItem.overflow` 생성자 및 stagger 임계값 제거
- [x] `_PositionedItem`에 `groupEvents` 필드 추가 (N≥4)
- [x] `TimeGrid` → `ConsumerStatefulWidget` 전환
- [x] `_selectedId`, `_highlightedId` 로컬 상태 추가

### 9-3: 모달 위젯 신규
- [x] `reservation_detail_modal.dart` — 하프 시트 플레이스홀더
- [x] `reservation_list_modal.dart` — N≥4 그룹 목록 모달

### 9-4: TimeGrid 탭 인터랙션 3가지 흐름
- [x] 일반 셀 탭: 하이라이트 + z-순서 최상단 + 상세 모달
- [x] N≥4 그룹 탭: 목록 모달 → 선택 → 상세 모달
- [x] isContinuation 탭: pendingHighlightId + 날짜 이동 + 수직 스크롤 + 상세 모달

### 9-5: three_day_calendar.dart 수정
- [x] `ReservationDisplayData` 생성 로직 수정 (summary 내장)
- [x] mock `Reservation` 맵 추가
- [x] `scrollToTimeTrigger` listen + 페이지 이동 완료 후 수직 스크롤

---

## Phase 10: 모달 UI 버그 수정 ✅ (완료 — Android 너비 이슈 미결)

**파일:** `reservation_detail_modal.dart`, `reservation_list_modal.dart`

> Flutter 3.41.6 업그레이드로 `showCupertinoSheet`에 `topGap`, `showDragHandle` 파라미터 사용 가능.

### 10-1: ReservationDetailModal ✅

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
- [x] `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가
- [x] `DraggableScrollableSheet`: `snap: true`, `snapSizes: [0.5, 1.0]`, `minChildSize: 0.3` → 스냅백/dismiss 분리
- [x] `Column` → `SingleChildScrollView(controller: scrollController)` 래핑 → 드래그 확장 활성화
- [x] 위젯 내부 `if (Platform.isAndroid)` 수동 pill 추가
  - (showModalBottomSheet의 showDragHandle은 DraggableScrollableSheet 밖에 렌더링되어 사용 불가)

**iOS** (`showCupertinoSheet`):
- [x] `showDragHandle: true` 추가 → Grabber 자동 표시 (CupertinoSheet는 정상 위치에 렌더링)
- [ ] `topGap` 미설정 → 추후 입력폼 Phase에서 피그마 537px 기준으로 설정 (미결)

> **설계 메모**: "절반(0.5)"은 임시값 — 실제로는 예약 입력폼의 특정 필드까지 보이는 높이

### 10-2: ReservationListModal ✅

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
- [x] `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가 (showDragHandle 미사용)
- [x] `DraggableScrollableSheet(initial: 0.5, min: 0.3, max: 1.0, snap: true, snapSizes: [0.5, 1.0])` 적용
- [x] `ScrollController? scrollController` 파라미터 추가 + `SingleChildScrollView`에 연결
- [x] 위젯 내부 `if (Platform.isAndroid)` 수동 pill 추가

**iOS** (`showCupertinoSheet`):
- [x] `showDragHandle: true` 추가
- [x] `topGap: 0.5` → 화면 하단 50% 차지 (비율값, 0.0~0.9)

### 10-3: Android/iOS 공통 구조 정리 ✅

- [x] `backgroundColor: Colors.transparent` 제거 — `showModalBottomSheet` 자체 Material 배경 사용
- [x] 수동 Grabber pill 제거 — `showDragHandle: true` 사용
- [x] `Material` 래퍼 제거 — 불필요
- [x] `SizedBox(width: double.infinity)` 루트 위젯으로 추가 — 전체 너비 보장

### 10-4: iOS topGap 비율 버그 수정 ✅

- **원인**: `topGap: MediaQuery.of(context).size.height * 0.5` (≈406) → Flutter assert 범위(0.0~0.9) 초과
  - `showCupertinoSheet` 내부 `assert(topGap == null || (topGap >= 0.0 && topGap <= 0.9))`
  - debug 모드에서 assertion 오류 → 모달 미표시 ("아예 보이지도 않아")
- **수정**: `topGap: 0.5` (비율: 화면 상단 50% gap = 시트가 하단 50% 차지)
- [x] `reservation_list_modal.dart` 수정 완료

### 10-5: iOS 투명 배경 수정 ✅

- **원인**: `showCupertinoSheet` 자체 배경 미제공. `CupertinoSheetRoute.buildContent`는 `ClipRSuperellipse`로 클리핑만 하며 배경색 없음. 콘텐츠 위젯이 배경을 직접 제공해야 함.
- **수정**: 두 모달 위젯 빌드 루트에 `Material` 추가 → 테마 surface 색상으로 배경 제공
- [x] `reservation_detail_modal.dart` 수정 완료
- [x] `reservation_list_modal.dart` 수정 완료

### 10-6: 리스트 모달 scrim + 탭 dismiss + 동시 애니메이션 ✅

**시도 이력 및 최종 결론 — `showCupertinoSheet`로 scrim 구현 불가**:
1. `OverlayEntry(ModalBarrier)` 직접 삽입 → Navigator.rearrange 후 최상단에 남아 모달 위를 덮음
2. `PageRouteBuilder` scrim route (below sheet) + `GestureDetector` → `CupertinoSheetRoute`가 투명하지만 blocking인 `ModalBarrier(dismissible:false, behavior:opaque)`를 렌더링하여 scrim의 GestureDetector에 터치 미전달
3. `navigator.removeRoute(scrimRoute)` → exit 애니메이션 없이 즉시 제거 (페이드아웃 불가)
4. `PageRouteBuilder` scrim + sheet 동시 애니메이션 → 별도 route이므로 animation controller 동기화 구조적 불가

**최종 해결**: `showModalBottomSheet`로 iOS/Android 통합 (플랫폼 분기 제거)
- `showModalBottomSheet`의 내장 기능: scrim 애니메이션 ✓, `isDismissible: true` 탭 dismiss ✓, sheet 슬라이드와 동기화된 fade ✓
- `DraggableScrollableSheet(snap: true, snapSizes: [0.5, 1.0])` → iOS/Android 공통 detent 동작
- `showCupertinoSheet` 포기: 배경 scale-down 효과·spring 물리 애니메이션 소실이나 기능 우선
- [x] `reservation_list_modal.dart` — iOS 분기 제거, `showModalBottomSheet` 단일 구현으로 교체

### 10-7: iOS 스타일 커스텀 Grabber + 모달 스타일 상수화 ✅

- [x] `colors.dart`에 `modalGrabberColor` (`0xFFB5B5BB`), `modalGrabberDarkColor` (`oxFF585858`), `modalBarrierColor` (`0x33000000`) 추가
- [x] `ui_constants.dart`에 `modalTopCornerRadius` (`10.0`) 추가
- [x] `reservation_list_modal.dart` — `showDragHandle: true` 제거, 커스텀 Grabber(36×5, top:6, radius:2.5) 적용, 상수 참조로 교체
- [x] `store_address_input_screen.dart` (Android) — 동일 Grabber + 상수 적용

### 10-8: ReservationDetailModal Android Grabber + 모달 스타일 적용 ✅

- [x] `showDragHandle: true` 제거
- [x] `barrierColor: modalBarrierColor`, `shape`, `clipBehavior` 적용
- [x] 위젯 루트를 `Material(Column([커스텀 Grabber, Expanded(SingleChildScrollView)]))` 구조로 변경 — `reservation_list_modal`과 동일
- **결정 근거**: 입력폼 구현 시 `topGap` 기반 높이 조절로 해결 시도. 어려울 경우 `showModalBottomSheet` 통합 검토.
- **미결**: `topGap` 최종값 설정 (피그마 safeArea 제외 537px → 비율 계산) → 예약 입력폼 Phase에서 처리

### 10-9: StoreAddressInputScreen iOS showCupertinoSheet 유지 결정 ✅ (결정 사항)

- [x] iOS: `showCupertinoSheet(enableDrag: false)` 복원 — native 시트 그대로 사용
- [x] Android: `showModalBottomSheet` + 커스텀 Grabber + 모달 스타일 상수 유지

---

## Phase 19: AppBarActionButton isRegularWeight + 모달 취소 버튼 통합 ✅

**파일:** `app_bar_action_button.dart`, `app_bar_back_button.dart`, `reservation_detail_modal.dart`

- [x] **19-1**: `AppBarActionButton`에 `isRegularWeight` bool 파라미터 추가
  - `false`(기본): `FontWeight.w600` (semibold)
  - `true`: `FontWeight.normal` (regular)
- [x] **19-2**: `AppBarModalBackButton` — Phase 16~18 변경사항 롤백, xmark 아이콘 전용으로 복원
- [x] **19-3**: `reservation_detail_modal.dart` — leading을 `AppBarActionButton(label: '취소', isRegularWeight: true)`로 변경, `app_bar_back_button.dart` import 제거

---

## Phase 18: AppBarModalBackButton OverflowBox 적용 ← 롤백 (Phase 19)

---

## Phase 17: CustomAppBar leadingWidth 파라미터 추가 ← 롤백 (Phase 18)

---

## Phase 16: AppBarModalBackButton label 파라미터 추가 ✅

**파일:** `lib/presentation/commons/widgets/app_bar/app_bar_back_button.dart`, `reservation_detail_modal.dart`

- [x] **16-1**: `AppBarModalBackButton`에 `final String? label` 파라미터 추가
  - `label != null` → `TextButton(Text(label!, style: titleLarge + normal weight))` 렌더링
  - `label == null` → 기존 xmark 아이콘 동작 유지
  - 스타일: `textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal, color: colorScheme.primary)`
- [x] **16-2**: `reservation_detail_modal.dart` — `leading: AppBarActionButton('취소')` → `AppBarModalBackButton(label: '취소')`로 교체

---

## Phase 15: ModalBodyPadding 컴포넌트화 ✅

**파일:** `lib/presentation/commons/widgets/modal_body_padding.dart` (신규), `reservation_list_modal.dart`

- [x] **15-1**: `ModalBodyPadding` 위젯 신규 생성
  - 위치: `lib/presentation/commons/widgets/modal_body_padding.dart`
  - `SafeArea(top: false) + Padding(fromLTRB(16, 16, 16, 8))` 패턴 캡슐화
  - 기본값: `EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8)`
  - `padding` 파라미터로 커스터마이징 가능
- [x] **15-2**: `ReservationListModal` — `SafeArea + Padding` → `ModalBodyPadding` 교체

---

## Phase 14: 모달 AppBar 투명 배경 + 14px 간격 + 취소 버튼 ✅

**파일:** `reservation_list_modal.dart`, `reservation_detail_modal.dart`

- [x] **14-1**: 두 모달 — Grabber `Padding(top:6)` → `SizedBox(height:14, child: Center(pill))` 교체
  - 모달 상단~AppBar 거리 = 14px (pill은 그 안에서 수직 중앙)
- [x] **14-2**: 두 모달 — CustomAppBar를 `Theme` 래퍼로 감싸 투명 배경 적용
  - `appBarTheme.backgroundColor = Colors.transparent`
  - `appBarTheme.surfaceTintColor = Colors.transparent`
  - `appBarTheme.shadowColor = Colors.transparent`
- [x] **14-3**: 리스트 모달 — `showModalBottomSheet`의 `backgroundColor: systemGroupedBackground` 유지 (시트 전체 배경), AppBar 투명 → AppBar가 systemGroupedBackground로 보임
- [x] **14-4**: 세부 모달 — `Material()` → `Material(color: context.systemGroupedBackground)` (iOS showCupertinoSheet 배경 제공)
- [x] **14-5**: 세부 모달 — `leading: AppBarActionButton(label: '취소', ...)` 추가 (→ Phase 16에서 `AppBarModalBackButton(label: '취소')`로 교체)
- [x] **14-6**: `context_colors.dart` import 추가 (detail modal)

---

## Phase 13: AppBarActionButton + 리스트 모달 배경색 분리 ✅

**파일:** `reservation_detail_modal.dart`, `reservation_list_modal.dart`

- [x] **13-1**: `ReservationDetailModal` — `TextButton('편집')` → `AppBarActionButton(label: '편집')` 교체
- [x] **13-2**: `ReservationListModal` — Grabber+AppBar 영역은 시트 기본 surface 색, 콘텐츠 영역은 `ColoredBox(systemGroupedBackground)` 분리
  - **원인**: `showModalBottomSheet`의 `backgroundColor: systemGroupedBackground`가 Grabber 포함 전체 시트에 적용 → AppBar 위에 회색 노출
  - **해결**: `backgroundColor` 제거 → `Expanded`를 `ColoredBox(systemGroupedBackground)`로 감쌈
  - **구조**: Grabber(surface) + AppBar(surface) + `Expanded(ColoredBox(systemGroupedBackground, ...))`

---

## Phase 12: 모달 AppBar + 인원 수 표시 + stagger overflow 목데이터 ✅

**파일:** `reservation_list_modal.dart`, `reservation_detail_modal.dart`, `three_day_calendar.dart`

- [x] **12-1**: `ReservationListModal` — `CustomAppBar(title: '예약 목록', leading: SizedBox.shrink())` Grabber 아래에 추가
- [x] **12-2**: `ReservationListModal` — 고객명을 `'고객명 · N인'` 형식으로 변경
- [x] **12-3**: `ReservationDetailModal` — `CustomAppBar(title: '예약 정보', leading: SizedBox.shrink(), actions: ['편집' TextButton])` 추가
- [x] **12-4**: `ReservationDetailModal` — iOS `showCupertinoSheet`에서 `showDragHandle: true` 제거 (위젯 내 Grabber와 중복 방지)
- [x] **12-5**: 목데이터 e24~e27 추가 (모레 12:00~15:00, 20분 stagger, N=4 overflow)
  - e24: 12:00~14:00 (red, 강예린, 2인)
  - e25: 12:20~14:20 (orange, 조현우, 3인)
  - e26: 12:40~14:40 (yellow, 문소리, 1인)
  - e27: 13:00~15:00 (green, 변요한, 4인)
  - 13:00에 4개 동시 활성 → max_col=3, N=4, overflow ✅

---

## Phase 11: StoreColor 통합 + 리스트 모달 배경색 ✅

**파일:** `lib/presentation/colors.dart`, `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`

- [x] **11-1**: `colors.dart` 예약 색상 상수 21개 삭제 (StoreColor enum으로 통합)
- [x] **11-2**: `showReservationListModal` → `backgroundColor: context.systemGroupedBackground` 추가

---

## 시각적 검증 항목

- [x] **V-1**: 오늘 종일 행 - 초록 확정 셀
- [x] **V-2**: 오늘 07:00~08:30 - 초록 확정 (1.5시간)
- [x] **V-3**: 오늘 10:00 N=4 → 오버플로우 셀, 멀티컬러 스트립 표시
- [x] **V-4**: 내일 09:00 N=2 delta=0 → cellWidth stagger, 이름 3자 노출
- [x] **V-5**: 내일 13:00 N=3 delta=0 → cellWidth stagger, 이름 1~2자 노출
- [x] **V-6**: 내일 17:00 N=2 delta=20분 → 8px stagger (delta>0 규칙)
- [x] **V-7**: 내일 20:30 N=2 delta=30분 → 8px stagger (delta>0 규칙)
- [x] **V-14**: 오늘 22:00 → 내일 02:00 자정 넘김:
  - 오늘 22:00~24:00: 정상 셀, 하단 코너 없음·구분선 밀착
  - 내일 00:00~02:00: 배경+스트립만, 상단 코너 없음·구분선 밀착
  - 바운스 시: 오늘 열 bottom 바운스 → 셀 아래로 이어짐, 내일 열 top 바운스 → 셀 위로 이어짐
- [x] **V-8**: 모레 20:00 N=2 delta=60분 → 8px stagger (back 셀 strip+gap만 노출)
- [x] **V-9**: 좌측 스트립(Foreground) vs 우측 배경(Background) 확인
- [x] **V-10**: 아이콘 셀 왼쪽에서 4px 간격
- [x] **V-11**: 셀 외곽선 0.5px
- [x] **V-12**: 다크 모드 외곽선 자동 적응
- [x] **V-13**: 핀치 줌 아웃 → hourHeight=36 이하 제한 확인

---

## Phase 22: 리스트 모달 chevron 크기 수정 ✅

**파일:** `reservation_list_modal.dart`

- [x] **22-1**: chevron `Icon(size: 10)` → `ConstrainedBox(maxWidth: 10) + Icon()` 패턴으로 교체
  - `TitleNavigationButton`과 동일한 방식
  - `size: 10` → 아이콘 글리프 자체 10pt (너무 가늘고 작게 보임)
  - `ConstrainedBox(maxWidth: 10)` → 아이콘은 기본 24pt로 렌더링, 너비만 10px 제한 → 적절한 굵기

---

## Phase 21: ModalAppBar 컴포넌트화 + 하단 구분선 제거 ✅

**파일:** `lib/presentation/commons/widgets/app_bar/modal_app_bar.dart` (신규), `reservation_detail_modal.dart`, `reservation_list_modal.dart`

- [x] **21-1**: `ModalAppBar` 위젯 신규 생성
  - 위치: `lib/presentation/commons/widgets/app_bar/modal_app_bar.dart`
  - `CustomAppBar` 래퍼 + Theme 오버라이드 캡슐화
  - `shape: RoundedRectangleBorder()` → 앱 테마 `Border(bottom: ...)` 구분선 제거
  - 배경/surfaceTint/shadow 투명 처리 포함
  - `leading` 기본값: `SizedBox.shrink()` (Navigator back button 방지)
- [x] **21-2**: `ReservationDetailModal` — `Theme(...)` + `CustomAppBar(...)` → `ModalAppBar(...)` 교체
- [x] **21-3**: `ReservationListModal` — 동일하게 교체

> **구분선 원인**: `my_app.dart` AppBarTheme의 `shape: Border(bottom: BorderSide(...))`.
> `ModalAppBar`에서 `shape: RoundedRectangleBorder()` (테두리 없음)로 오버라이드하여 해결.

---

## Phase 20: ModalGrabber 컴포넌트화 ✅

**파일:** `lib/presentation/commons/widgets/modal_grabber.dart` (신규), `reservation_detail_modal.dart`, `reservation_list_modal.dart`

- [x] **20-1**: `ModalGrabber` 위젯 신규 생성
  - 위치: `lib/presentation/commons/widgets/modal_grabber.dart`
  - 높이 14px SizedBox, 36×5 pill, 코너 반지름 2.5
  - 다크 모드 자동 대응 (`modalGrabberDarkColor` / `modalGrabberColor`)
- [x] **20-2**: `ReservationDetailModal` — 인라인 Grabber 코드 → `const ModalGrabber()` 교체, `isDarkMode` 변수 제거
- [x] **20-3**: `ReservationListModal` — 인라인 Grabber 코드 → `const ModalGrabber()` 교체, `isDarkMode` 변수 제거

---

## 스코프 아웃 (추후)

- 실제 데이터 연결 — Reservation 도메인 엔티티 + Riverpod provider
- 빌드 러너 불필요 — 코드 생성 없음 (freezed/riverpod 미사용)
