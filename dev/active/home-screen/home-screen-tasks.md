# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-20

## Phase 1~7: 초기 구현 ✅ (완료)
- 상수, 상태관리, 탭바, 네비바, 월간 캘린더, 3일 캘린더, HomeScreen 조합 모두 완료

## Phase 8: 피드백 반영 1차 ✅ (완료)
- [x] 8-1: HomeNavBar 플랫폼별 높이 (`Platform.isIOS ? 44 : kToolbarHeight`)
- [x] 8-2: 날짜 picker 플랫폼별 모달 (iOS Cupertino / Android Material)
- [x] 8-3: 월간 캘린더 좌우 PageView (월 단위 스냅, PageController initialPage=10000)
- [x] 8-4: 월간 캘린더 선택 셀 40×40 명확화 (Center > Container 구조)
- [x] 8-5: 월간 캘린더 overflow `mainAxisSize: MainAxisSize.min` 추가
- [x] 8-6: 3일 헤더 수직→수평 레이아웃 (Row, 간격 4)
- [x] 8-7: 3일 캘린더 날짜 열 사이 세로 구분선
- [x] 8-8: 시간 열↔날짜 열 사이 구분선 + 1px gap
- [x] 8-9: 스크롤 `BouncingScrollPhysics()`
- [x] 8-10: 3일 캘린더 헤더 PageView 연속 스크롤+스냅

## Phase 9: 피드백 반영 2차 ✅ (완료)
- [x] 9-1: 요일 헤더 구분선 제거 (`_ThreeDayHeaderPage` 구분선 없음)
- [x] 9-2: 0~1시 높이 - 시간 레이블 `Transform.translate(0, -12)`으로 구분선 위로 이동
- [x] 9-3: 현재 시간 캡슐 `borderRadius(100)`, 텍스트 `height: 1.0`
- [x] 9-4: 월간 캘린더 overflow → `OverflowBox(maxHeight)` 로 근본 해결
- [x] 9-5: 3일 캘린더 좌우 스크롤 → PageView 전체 영역 + shared ScrollController
- [x] 9-6: picker 완료 버튼에서만 날짜 적용 (`StatefulBuilder` + `tempDate`)
- [x] 9-7: 상수 변경 (`monthlyCalendarHeight=260`, `threeDayHeaderHeight=28`)
- [x] 9-8: bouncing 구분선 → `LayoutBuilder` + Positioned 오버레이 (ThreeDayCalendar Stack)
- [x] 9-9: 0시/24시 구분선 제거 (루프 `1..23`으로 변경)

## Phase 10: 피드백 반영 3차 ✅ (완료)
- [x] 10-1: 월간 캘린더 overflow → `OverflowBox` 로 재수정
- [x] 10-2: picker 날짜 선택 후 월간 캘린더 선택 표시 → 이슈 10-7 해결로 자동 해결
- [x] 10-3: 시간 열 구분선 시작 위치 → `top: threeDayHeaderHeight + 0.5` (종일 행부터)
- [x] 10-4: 열 사이 구분선 bouncing 시에도 연속 → LayoutBuilder 오버레이로 처리
- [x] 10-5: 0~1시 영역 넓음 → 레이블 `Transform.translate(0,-12)` 구분선 위로
- [x] 10-6: 현재 시간 캡슐 위치 → `SizedBox(width: timeColumnWidth+0.5-capsuleWidth)` 좌측 여백
- [x] 10-7: 날짜 이동 시 월간 캘린더 상태 유지 → `selectDate`/`goToToday`에서 `isMonthlyCalendarVisible` 변경 제거

## Phase 11: 피드백 반영 4차 ✅ (완료)
- [x] 11-1: 월간 캘린더 날짜 선택 시 3일 캘린더 슬라이드 애니메이션 제거 → `animateToPage` → `jumpToPage`
- [x] 11-2: 피커/오늘 버튼 → 월간 캘린더 표시 월 + 네비바 연/월 미반영 수정
- [x] 11-3: 피커 모달에 grabber 표시 + 끌어내려서 dismiss 지원
- [x] 11-4: 네비바 chevron 크기 12×7, 간격 8 (커스텀 CustomPaint)
- [x] 11-5: 현재 시간 캡슐이 시간 레이블을 가리도록 수직 위치 보정
- [x] 11-6: 월간 캘린더 펼쳤을 때 3일 캘린더와 간격 제거 → 헤더 SizedBox(height: 60) 고정
- [x] 11-7: 오늘 버튼 클릭 시 3일 캘린더 현재 시간 위치로 스크롤
- [x] 11-8: 현재 시간 타이머 딜레이 → 정각에 맞춘 타이머로 교체

## Phase 12: 피드백 반영 5차 ✅ (완료)

### 12-1: 애니메이션 정책 수정 ✅
- `CalendarTransitionKind` enum + `consumeThreeDayTransition()` / `consumeMonthlyTransition()` consume 패턴 구현
- `selectDateFromSwipe()` (월 경계 통과 시만 animate) / `selectDateFromPicker()` (두 캘린더 모두 animate) 추가
- `goToToday()` 수정 — 두 플래그 animate
- `monthly_calendar.dart` `_syncPageToMonth` animateToPage/jumpToPage 분기 처리

### 12-2: 월간 캘린더 오늘 날짜 UI ✅
- `monthly_calendar_grid.dart` — isToday 판별 추가
- 오늘+선택: label 사각형 40×40 + systemBackground 원 24×24 + label 숫자
- 오늘+미선택: label 원 24×24 + systemBackground 숫자
- 일반 선택: 기존 유지

### 12-3: 네비바 버튼 크기 통일 ✅
- 오늘 버튼 + 피커 아이콘 모두 24×24 (터치 영역 44×44 유지)

### 12-4: 3일 캘린더 1일 단위 스크롤 ✅
- `PageController(viewportFraction: 1/3)` — 1페이지=1일, 3일 동시 표시
- 1일씩 스냅, 빠른 스와이프 시 여러 날 이동

### 12-5: 3일 캘린더 시간 열 고정 구조 ✅
- 고정 시간 열 (시간 레이블 + CurrentTimeCapsule) + PageView (날짜 열만 스크롤)
- 페이지별 개별 ScrollController + `_syncAllScrollControllers` (`_isSyncing` 재진입 방지)
- `_evictDistantControllers` — ±5 범위 밖 컨트롤러 dispose
- `three_day_header.dart` 삭제 (`_DayHeaderCell` 인라인 통합)

### 12-6: CurrentTimeIndicator y축 정렬 ✅
- `currentTimeTopPosition()` -6px 보정으로 시간 레이블 중앙과 일치
- `CurrentTimeCapsule` / `CurrentTimeLine` 분리 (각각 Positioned 직접 반환)
- `CurrentTimeLine` 모든 날짜 열에 표시: 오늘 systemRed, 비오늘 30% opacity

---

## Phase 13: 피드백 반영 6차 (다음 세션 구현 예정)

### 버그 수정 (우선순위 높음)

- [ ] **13-3**: 오늘 날짜 초기 위치 오류 — 오늘이 3일 캘린더 **첫 번째 열**에 표시되어야 함 (현재 가운데 열)
  - `_referenceDate` 또는 `initialPage=10000` 기준 날짜 계산 재검토
- [ ] **13-4**: 현재 시간 UI 위치 오류 — 2시 2분인데 2시 구분선보다 위에 표시됨
  - `currentTimeTopPosition()` `-6px` 보정값 제거 또는 재계산 필요
  - 현재: `hourHeight * (hour + minute/60) - capsuleHeight/2` → 캡슐 보정이 위치를 앞당김
- [ ] **13-10**: 시간 라벨과 구분선 X축 정렬 불일치 — `Transform.translate(0, -12)` 값 재조정
  - 목표: 시간 라벨 세로 중앙이 구분선과 일치 (현재는 구분선 '위'로 올라가 있음)
- [ ] **13-11**: `CurrentTimeLine` 날짜별 Y위치 틀어짐 — 페이지별 ScrollController 오프셋 차이 여부 확인

### UI 개선

- [ ] **13-5**: 현재 시간 캡슐 Y축 정렬 개선
  - **방법**: 텍스트 라벨 먼저 시간 구분선과 Y축 정렬 → 그 위에 캡슐 씌우기
  - 캡슐 높이 조정 가능 (현재 `currentTimeCapsuleHeight = 13`)
- [ ] **13-6**: 핀치 줌 제스처 영역 확장 — 좌측 고정 시간 열에서도 인식되어야 함
  - `GestureDetector`를 `ThreeDayCalendar` 최상위 레벨로 이동 또는 래핑
- [ ] **13-7**: 월간 캘린더 요일 헤더 높이 → **20px** (현재 `monthlyCalendarWeekdayRowHeight = 36`)
  - `ui_constants.dart` 상수 변경 + 레이아웃 업데이트
- [ ] **13-8**: 월간 캘린더 날짜 그리드 상하좌우 **8px 패딩** 추가
  - 전체 높이 260px 유지, 패딩 추가 시 내부 셀 크기 조정 필요할 수 있음
- [ ] **13-9**: 월간 캘린더 날짜 선택 시 3일 캘린더 `animateToPage` 적용
  - Phase 11-1에서 `jumpToPage`로 변경했던 것을 `animateToPage`로 되돌림
  - `home_calendar_controller.dart`의 `CalendarTransitionKind` 분기 수정

### 애니메이션 개선

- [ ] **13-1**: 3일 캘린더 스크롤 중 월간 캘린더 선택 UI 부드럽게 이동
  - 현재: `selectedStartDate` 변경 시 월간 캘린더 선택 셀이 즉시(딱딱하게) 변경됨
  - 목표: `AnimatedContainer` 또는 `AnimatedPositioned`로 선택 셀 이동 애니메이션

### 버그 수정 (낮은 우선순위)

- [ ] **13-2**: Bouncing 스크롤 후 입력 차단 현상
  - 상단/하단 끝까지 스크롤 후 원래 크기로 돌아오는 동안 스크롤 불가
  - `BouncingScrollPhysics` + `_syncAllScrollControllers` 상호작용 문제로 추정

---

## 최종 검증 (Phase 12 기준 — Phase 13 완료 후 재검증 필요)
- [x] 월간 캘린더 overflow 없이 접힘/펼침
- [x] 월간 캘린더 좌우 스와이프 월 이동
- [x] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [x] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅)
- [x] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [x] 3일 캘린더 세로 구분선: 종일 행부터 bouncing 시에도 연속
- [x] 열 사이 구분선 bouncing 시에도 연속
- [ ] 현재 시간 캡슐 위치, 둥근 모서리, 텍스트 정렬 정상 (13-4, 13-5 수정 후 재검증)
- [x] picker 완료 버튼에서만 날짜 이동 + animateToPage
- [ ] 오늘 버튼 → 3일 캘린더 animateToPage + 현재 시간 스크롤
- [ ] 월간 캘린더 날짜 선택 → animateToPage (13-9 수정 후)
- [x] 오늘 날짜 UI: 선택 시 label 사각형 + systemBackground 원(24×24) + label 숫자
- [x] 오늘 날짜 UI: 미선택 시 label 원(24×24) + systemBackground 숫자
- [x] 0시/24시 구분선 없음, 1~23시 레이블 구분선과 Y축 정렬 (13-10 수정 후 재검증)
- [x] 다크 모드 색상 정상 표시
- [x] `dart analyze lib/` 에러 없음
