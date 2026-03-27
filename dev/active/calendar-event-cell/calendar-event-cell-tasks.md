# 캘린더 일정 셀 - 작업 체크리스트

Last Updated: 2026-03-27 (2차)

---

## Phase 1: 색상 상수 추가

**파일:** `lib/presentation/colors.dart`
**크기:** S

- [ ] **1-1**: Background 색상 7개 추가
  - `redBackground(#FF9E99)`, `orangeBackground(#FFD599)`, `yellowBackground(#FFEB99)`
  - `greenBackground(#AEEABD)`, `blueBackground(#99CAFF)`
  - `indigoBackground(#AEADEB)`, `purpleBackground(#D7A9EF)`

- [ ] **1-2**: Foreground 색상 7개 추가
  - `redForeground(#FF3B30)`, `orangeForeground(#FF9500)`, `yellowForeground(#FFCC00)`
  - `greenForeground(#34C759)`, `blueForeground(#007AFF)`
  - `indigoForeground(#5856D6)`, `purpleForeground(#AF52DE)`

- [ ] **1-3**: Label 색상 7개 추가
  - `redLabel(#990800)`, `orangeLabel(#995900)`, `yellowLabel(#997A00)`
  - `greenLabel(#207936)`, `blueLabel(#004999)`
  - `indigoLabel(#1F1E7B)`, `purpleLabel(#5E1980)`

---

## Phase 2: 줌 범위 수정

**파일:** `lib/constants/ui_constants.dart`
**크기:** S

- [ ] **2-1**: `defaultHourHeight` 36.0 → 40.0 변경
- [ ] **2-2**: `minHourHeight` 18.0 → 40.0 변경
  - 주의: `HomeCalendarController.build()`에서 초기값이 clamp 없이 주입됨 → 두 값을 함께 변경해야 앱 시작 시 hourHeight=36 동작 방지
- [ ] **2-3**: `HomeCalendarController`의 `loadHourHeight` 반환 시 `.clamp(minHourHeight, maxHourHeight)` 적용 확인 및 추가

---

## Phase 3: ReservationCell 위젯 구현

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart` (신규)
**크기:** M

- [ ] **3-1**: `ReservationStatus` enum 구현
  - `confirmed`, `pendingPayment`, `cancelled`

- [ ] **3-2**: `ReservationCellColorTheme` enum 구현
  - 7개 케이스: `red`, `orange`, `yellow`, `green`, `blue`, `indigo`, `purple`
  - getter 3개: `backgroundColor`, `foregroundColor`, `labelColor`
  - `lib/presentation/colors.dart`의 색상 상수 참조

- [ ] **3-3**: `ReservationDisplayData` 클래스 구현
  - 필드: `reserverName`, `headcount`, `phoneNumber`, `status`, `colorTheme`, `isAllDay`, `startTime?`, `endTime?`
  - `// TODO: 예약 도메인 엔티티 정의 후 교체 예정` 주석 추가

- [ ] **3-4**: `_StatusIcon` private 위젯 구현 (모두 SVG)
  - confirmed: `assets/images/icons/checkmark_circle_fill.svg`
  - pendingPayment: `assets/images/icons/circle_dashed.svg`
  - cancelled: `assets/images/icons/circle_slash.svg`
  - 공통: `SvgPicture.asset(path, width: 12, height: 12, colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn))`

- [ ] **3-5**: `ReservationCell` StatelessWidget 구현
  - `ClipRRect(borderRadius: BorderRadius.circular(4))`
  - `Stack`: foreground 배경 + 4px background 스트립 + 0.5px 외곽선 overlay + 콘텐츠 Row
  - Row: `SizedBox(4)` + Padding(top:2)+아이콘 + `SizedBox(2.5)` + Padding(top:2)+텍스트 Column
  - 텍스트 Column: `labelSmall` (fontSize:10, height:1.5) 그대로 사용 (height 오버라이드 불필요)
    - "이름 · N인" / "010-XXXX-XXXX", maxLines:1, overflow:ellipsis
  - `crossAxisAlignment: CrossAxisAlignment.start`

---

## Phase 4: AllDayCell 수정

**파일:** `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`
**크기:** S

- [ ] **4-1**: `AllDayCell`에 `List<ReservationDisplayData> events` 파라미터 추가
- [ ] **4-2**: `SizedBox` → `SizedBox + Stack` 구조로 변경
- [ ] **4-3**: 각 이벤트에 `Positioned(left: 1, right: 8, top: 1, bottom: 4)` 적용
- [ ] **4-4**: `// TODO: 다중 이벤트 겹침 처리 미구현` 주석 추가

---

## Phase 5: TimeGrid 수정

**파일:** `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`
**크기:** S

- [ ] **5-1**: `TimeGrid`에 `List<ReservationDisplayData> events` 파라미터 추가
- [ ] **5-2**: `_topOffset(DateTime start, double hourHeight)` 구현
  - `hourHeight * (start.hour + start.minute / 60) + 0.5`
- [ ] **5-3**: `_cellHeight(DateTime start, DateTime end, double hourHeight)` 구현
  - `hourHeight * end.difference(start).inMinutes / 60 - 1.0`
  - `.clamp(1.0, double.infinity)` 적용
- [ ] **5-4**: Stack에 이벤트 Positioned 추가
  - `left: 1, right: 8`, `top: _topOffset`, `height: _cellHeight`

---

## Phase 6: ThreeDayCalendar 목업 데이터 추가

**파일:** `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`
**크기:** S

- [ ] **6-1**: `_buildMockEvents()` static 메서드 구현
  - 오늘 기준 상대 날짜 사용 (`DateTime.now()` 기반)
  - 포함 이벤트 (7개, 3가지 상태 × 여러 색상):
    - 오늘 종일: confirmed + green
    - 오늘 07:00~08:30: confirmed + green
    - 오늘 10:00~13:00: cancelled + green (circle_slash)
    - 내일 10:00~14:00: pendingPayment + yellow (circle_dashed)
    - 내일 15:00~16:00: confirmed + blue (1시간 최소 셀 확인용)
    - 모레 종일: pendingPayment + orange
    - 모레 13:00~15:00: cancelled + purple

- [ ] **6-2**: `_eventsForDate(DateTime date, {required bool allDay})` 헬퍼 구현
- [ ] **6-3**: `AllDayCell(events: _eventsForDate(date, allDay: true))`로 업데이트
- [ ] **6-4**: `TimeGrid(events: _eventsForDate(date, allDay: false))`로 업데이트

---

## 시각적 검증 항목

- [ ] **V-1**: 오늘 종일 행 - 초록 확정 셀 (checkmark_circle_fill SVG)
- [ ] **V-2**: 오늘 07:00~08:30 - 초록 확정 (1.5시간 셀, 텍스트 2줄)
- [ ] **V-3**: 오늘 10:00~13:00 - 초록 취소 (circle_slash, 3시간 셀)
- [ ] **V-4**: 내일 10:00~14:00 - 노랑 대기 (circle_dashed, 노란 배경)
- [ ] **V-5**: 내일 15:00~16:00 - 파랑 확정 (1시간 최소 셀, 텍스트 ellipsis 확인)
- [ ] **V-6**: 모레 종일 - 주황 대기
- [ ] **V-7**: 모레 13:00~15:00 - 보라 취소
- [ ] **V-8**: 셀 외곽선 0.5px (systemBackground)
- [ ] **V-9**: 좌측 4px 진한 스트립 vs 나머지 배경 색상 차이 확인
- [ ] **V-10**: 다크 모드에서 외곽선 색상 자동 적응
- [ ] **V-11**: 핀치 줌 아웃 → hourHeight=40 이하 제한 확인
- [ ] **V-12**: SVG colorFilter 적용 (아이콘이 labelColor로 렌더링되는지)

---

## 스코프 아웃 (추후 구현)

- 동일 날짜 동일 시간대 다중 예약 겹침 레이아웃
- 예약 셀 탭 → 상세 화면 이동
- Riverpod provider 연결 (실제 예약 데이터)
