# 캘린더 일정 셀 - 작업 체크리스트

Last Updated: 2026-03-30 (Phase 10 구현 계획 확정 — Flutter 3.41.6 반영)

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

## Phase 10: 모달 UI 버그 수정 ⬜ (미착수 — 다음 작업)

**파일:** `reservation_detail_modal.dart`, `reservation_list_modal.dart`

> Flutter 3.41.6 업그레이드로 `showCupertinoSheet`에 `topGap`, `showDragHandle` 파라미터 사용 가능.

### 10-1: ReservationDetailModal

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
- [ ] `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가 → 너비 채움 버그 수정
- [ ] `DraggableScrollableSheet` 파라미터: `initialChildSize: 0.5, minChildSize: 0.5, maxChildSize: 1.0, expand: false` 유지
- [ ] `ReservationDetailModal` 내부: `Column` → `SingleChildScrollView(controller: scrollController, child: Column(...))` 로 감쌈 → 드래그 최대화 활성화

**iOS** (`showCupertinoSheet`):
- [ ] `showDragHandle: true` 추가 → Grabber 자동 표시 (수동 pill 코드 제거 가능)
- [ ] `topGap` 파라미터: 현재 플레이스홀더이므로 기본값 유지, 향후 입력폼 Phase에서 537px 기준으로 계산
- [ ] TODO 주석 업데이트 (Flutter 3.41.6에서 topGap/showDragHandle 사용 가능, detents는 여전히 미지원)

**초기 높이 주의사항**:
- 현재 플레이스홀더 단계 → 0.5(50%) 임시 사용
- 추후 입력폼 구현 Phase에서 피그마 537px 기준으로 옵션 A(하드코딩) vs 옵션 B(GlobalKey 동적) 결정

### 10-2: ReservationListModal

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
- [ ] `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가
- [ ] `DraggableScrollableSheet(initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 1.0, expand: false)` 적용
- [ ] `ScrollController? scrollController` 파라미터를 `ReservationListModal`에 추가
- [ ] `ReservationListModal` 내부 스크롤 가능 구조로 변경 (SingleChildScrollView 또는 ListView)

**iOS** (`showCupertinoSheet`):
- [ ] `showDragHandle: true` 추가 → Grabber 자동 표시
- [ ] `topGap`으로 초기 절반 높이 설정 (화면 높이의 절반 기준: `topGap = MediaQuery.of(context).size.height * 0.5`)

**공통**:
- [ ] `ReservationListModal` 위젯 내 수동 Grabber pill 제거 (iOS `showDragHandle`로 대체, Android는 `showDragHandle` 미지원이므로 위젯 내 pill 유지하거나 Material `showDragHandle` 확인)

---

## 시각적 검증 항목

- [ ] **V-1**: 오늘 종일 행 - 초록 확정 셀
- [ ] **V-2**: 오늘 07:00~08:30 - 초록 확정 (1.5시간)
- [ ] **V-3**: 오늘 10:00 N=4 → 오버플로우 셀, 멀티컬러 스트립 표시
- [ ] **V-4**: 내일 09:00 N=2 delta=0 → cellWidth stagger, 이름 3자 노출
- [ ] **V-5**: 내일 13:00 N=3 delta=0 → cellWidth stagger, 이름 1~2자 노출
- [ ] **V-6**: 내일 17:00 N=2 delta=20분 → 8px stagger (delta>0 규칙)
- [ ] **V-7**: 내일 20:30 N=2 delta=30분 → 8px stagger (delta>0 규칙)
- [ ] **V-14**: 오늘 22:00 → 내일 02:00 자정 넘김:
  - 오늘 22:00~24:00: 정상 셀, 하단 코너 없음·구분선 밀착
  - 내일 00:00~02:00: 배경+스트립만, 상단 코너 없음·구분선 밀착
  - 바운스 시: 오늘 열 bottom 바운스 → 셀 아래로 이어짐, 내일 열 top 바운스 → 셀 위로 이어짐
- [ ] **V-8**: 모레 20:00 N=2 delta=60분 → 8px stagger (back 셀 strip+gap만 노출)
- [ ] **V-9**: 좌측 스트립(Foreground) vs 우측 배경(Background) 확인
- [ ] **V-10**: 아이콘 셀 왼쪽에서 4px 간격
- [ ] **V-11**: 셀 외곽선 0.5px
- [ ] **V-12**: 다크 모드 외곽선 자동 적응
- [ ] **V-13**: 핀치 줌 아웃 → hourHeight=36 이하 제한 확인

---

## 스코프 아웃 (추후)

- 실제 데이터 연결 — Reservation 도메인 엔티티 + Riverpod provider
- 빌드 러너 불필요 — 코드 생성 없음 (freezed/riverpod 미사용)
