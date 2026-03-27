# 캘린더 일정 셀 - 작업 체크리스트

Last Updated: 2026-03-27 (8차 — 내부 top 패딩 1.5 확정)

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
- [x] **3-5**: `ReservationCell` widget

---

## Phase 4: AllDayCell 수정 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

- [x] **4-1~4-4**: events 파라미터, Positioned(left:1, right:8, top:1, bottom:4) 배치

---

## Phase 5: TimeGrid 수정 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

- [x] **5-1~5-4**: events 파라미터, _topOffset/_cellHeight 계산, Positioned 배치

---

## Phase 6: ThreeDayCalendar 목업 데이터 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

- [x] **6-1**: `_buildMockEvents()` 오늘 기준 7개 이벤트
- [x] **6-2**: `_eventsForDate()` 날짜 필터링
- [x] **6-3~6-4**: AllDayCell, TimeGrid에 연결

---

## 버그 수정 ✅

- [x] **Fix-1**: 셀 색상 반전 수정
  - 잘못됨: 좌측 스트립=~Background, 우측 배경=~Foreground
  - 수정됨: 좌측 스트립=~Foreground (진한 색), 우측 배경=~Background (연한 색)
  - 파일: `reservation_cell.dart` (build() 내 bgColor/fgColor 할당 교체)

- [x] **Fix-2**: 아이콘 라벨 영역 간격 수정
  - 잘못됨: SizedBox(width:4) → 아이콘이 스트립에 붙어있는 느낌
  - 수정됨: SizedBox(width:8) → 스트립 4px + 라벨 영역 왼쪽에서 4px 간격
  - 파일: `reservation_cell.dart` Row children 첫 번째 SizedBox

- [x] **Fix-3**: 아이콘 크기 / 상단 간격 / 우측 여백 / 자동 축소 / 세로 중앙 정렬
  - 아이콘 12×12 → 10×10
  - 상단 간격 `top:2` → `top:4`
  - 우측 최소 여백 `right:4` 추가 (iPhone 13 mini 텍스트 붙음 방지)
  - `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.topLeft)` 로 아이콘+텍스트 비율 축소
  - `SizedBox(height:15, Center(icon))` — labelSmall 라인 높이 기준으로 아이콘-첫 텍스트 중앙 정렬
  - `overflow: TextOverflow.ellipsis` 제거 (FittedBox가 처리)
  - 파일: `reservation_cell.dart`

- [x] **Fix-4**: minHourHeight 수정 및 bottom:4 롤백
  - minHourHeight 40 → 36 (사용자 정정: 최소 시간 간격 높이 36px, 1시간 셀 최소 35px 충족)
  - 6차에서 추가한 Padding(bottom:4) 롤백 — FittedBox 높이 제한으로 텍스트 축소 발생
  - 피그마 스펙: 내부 padding에 bottom 없음, 외부 Positioned(bottom:4)만 사용
  - 파일: `ui_constants.dart`, `reservation_cell.dart`

- [x] **Fix-5**: 내부 top 패딩 조정
  - 피그마 기준 셀 상단~아이콘 상단 = 4px
  - SizedBox(height:15)가 아이콘(10px)을 중앙정렬 → 아이콘 위 내부 여백 2.5px
  - 따라서 Padding top = 4 - 2.5 = **1.5px** (기존 top:4 → top:1.5)
  - 결과: 종일 셀 하단 여백 = 35 - 1.5 - 30 = 3.5px (기존 1px에서 개선)
  - 파일: `reservation_cell.dart` Padding(top: 1.5, right: 4)

---

## 시각적 검증 항목

- [ ] **V-1**: 오늘 종일 행 - 초록 확정 셀 (checkmark_circle_fill SVG)
- [ ] **V-2**: 오늘 07:00~08:30 - 초록 확정 (1.5시간 셀, 텍스트 2줄)
- [ ] **V-3**: 오늘 10:00~13:00 - 초록 취소 (circle_slash, 3시간 셀)
- [ ] **V-4**: 내일 10:00~14:00 - 노랑 대기 (circle_dashed, 노란 배경)
- [ ] **V-5**: 내일 15:00~16:00 - 파랑 확정 (1시간 셀, 텍스트 ellipsis 확인)
- [ ] **V-6**: 모레 종일 - 주황 대기
- [ ] **V-7**: 모레 13:00~15:00 - 보라 취소
- [ ] **V-8**: 좌측 스트립(~Foreground, 진한 색) vs 우측 배경(~Background, 연한 색) 확인
- [ ] **V-9**: 아이콘이 라벨 영역 왼쪽에서 4px 떨어진 위치 확인
- [ ] **V-10**: 셀 외곽선 0.5px (systemBackground)
- [ ] **V-11**: 다크 모드 외곽선 자동 적응
- [ ] **V-12**: 핀치 줌 아웃 → hourHeight=40 이하 제한 확인

---

## 스코프 아웃 (추후 구현)

- 동일 날짜 동일 시간대 다중 예약 겹침 레이아웃
- 예약 셀 탭 → 상세 화면 이동
- Riverpod provider 연결 (실제 예약 데이터)
