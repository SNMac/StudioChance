# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-20 (4차)

## Phase 1~14: 완료 ✅

## Phase 15: 피드백 반영 (진행 중)

### 완료

- [x] **15-4**: 월간→3일 animateToPage 중 monthly 캘린더 중간 달 표시 버그
  - `_ThreeDayCalendarState`에 `_isPageAnimating` 플래그 추가
  - `animateToPage` 중 `onPageChanged` → `selectDateFromSwipe` 차단
  - `.then()` 후 `_isPageAnimating = false` + 도착 페이지 수동 `selectDateFromSwipe` ✅

### 완료

- [x] **15-1**: 바운싱 스크롤 복원 + 스크롤 불가 현상 근본 해결
  - `time_grid.dart` `ClampingScrollPhysics` → `BouncingScrollPhysics` ✅
  - `three_day_calendar.dart` bouncing 범위 sync 차단 (`hasContentDimensions` 가드) ✅

- [x] **15-2**: 점포 필터 버튼 아이콘 — 이미 `CupertinoIcons.calendar_circle`로 복원되어 있음 ✅

- [x] **15-3**: 현재 시간 캡슐 구분선 갭 제거 — `right: -calendarDividerThickness` ✅

- [x] **15-4**: 월간→3일 animateToPage 중 monthly 중간 달 표시 버그 — `_isPageAnimating` 플래그 ✅

- [x] **15-5**: 월간 캘린더 AnimatedContainer — 이미 Container로 되어 있었음 ✅

- [x] **15-6**: GestureDetector → CupertinoButton 교체
  - `home_nav_bar.dart` 3곳 (`minimumSize: Size.zero, padding: EdgeInsets.zero`) ✅
  - `monthly_calendar_grid.dart` 날짜 셀 ✅

- [x] **15-7**: 날짜 열 구분선 Stack Positioned 오버레이 방식으로 전환
  - `DecoratedBox(right border)` 제거 → `LayoutBuilder + Positioned` 오버레이 2개 ✅

---

## Phase 16: 다음 단계 과제 (미착수)

- [ ] **16-1**: 캘린더 날짜 범위 확장 (2001.01.01 ~ 2100.12.31)
  - 현재 `initialPage=10000` → ±10000일 (약 27년) 만 접근 가능
  - `_referenceDate`를 고정 날짜로 변경 또는 `initialPage` 대폭 증가 필요
  - `DateTime(2001, 1, 1)` 기준으로 계산 시 `initialPage = DateTime.now().difference(DateTime(2001,1,1)).inDays`
  - 파일: `three_day_calendar.dart` `_initialPage`, `_referenceDate`

---

## 최종 검증 목록

- [x] 월간 캘린더 overflow 없이 접힘/펼침
- [x] 월간 캘린더 좌우 스와이프 월 이동
- [x] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [x] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅)
- [x] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [x] 네비바 animateToPage 중 중간값 없음 (`_isAnimating` ✅)
- [x] 시간 라벨 & 구분선 Y축 정렬 (`FractionalTranslation` ✅)
- [x] 오늘 날짜 UI 정상
- [x] 다크 모드 색상 정상
- [x] `dart analyze lib/` 에러 없음
- [x] 3일 캘린더 animateToPage 중 monthly 중간 상태 없음 (`_isPageAnimating` ✅)
- [x] 바운싱 스크롤 복원 + 바운싱 후 스크롤 정상 동작 (15-1) ✅
- [x] GestureDetector → CupertinoButton 교체 (15-6) ✅
- [x] 현재 시간 캡슐과 구분선 사이 갭 제거 (15-3) ✅
- [x] 날짜 열 구분선 틀어짐 없음 (15-7) ✅
- [x] 월간 캘린더 선택 UI 깜빡임 없음 (15-5) ✅
- [x] 점포 필터 버튼 아이콘 확인 (15-2) ✅
