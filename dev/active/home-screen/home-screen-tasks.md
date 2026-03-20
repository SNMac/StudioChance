# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-20 (4차)

## Phase 1~14: 완료 ✅

## Phase 15: 피드백 반영 (진행 중)

### 완료

- [x] **15-4**: 월간→3일 animateToPage 중 monthly 캘린더 중간 달 표시 버그
  - `_ThreeDayCalendarState`에 `_isPageAnimating` 플래그 추가
  - `animateToPage` 중 `onPageChanged` → `selectDateFromSwipe` 차단
  - `.then()` 후 `_isPageAnimating = false` + 도착 페이지 수동 `selectDateFromSwipe` ✅

### 미완료 (우선순위 순)

- [ ] **15-1**: 바운싱 스크롤 복원 + 스크롤 불가 현상 근본 해결
  - **현재 상태**: `ClampingScrollPhysics` 적용됨 → 바운싱 완전히 사라짐
  - **목표**: iOS 자연스러운 바운싱 복원 + 바운싱 후 스크롤 불가 현상 제거
  - **해결 방향**:
    1. `time_grid.dart` `ClampingScrollPhysics` → `BouncingScrollPhysics`
    2. `three_day_calendar.dart` `_controllerForPage` 리스너에서 bouncing 범위 sync 차단:
       ```dart
       final maxExtent = ctrl.position.maxScrollExtent;
       if (offset < 0 || offset > maxExtent) return;
       ```
  - 파일: `time_grid.dart` (physics), `three_day_calendar.dart` (_controllerForPage)

- [ ] **15-6**: GestureDetector → CupertinoButton 교체
  - **`home_nav_bar.dart`** (3곳):
    - 좌측 연월+chevron: `GestureDetector(onTap: toggleMonthlyCalendar)` → `CupertinoButton`
    - 점포 필터 버튼: `GestureDetector(onTap: _showStoreFilter)` → `CupertinoButton`
    - 오늘 날짜 버튼: `GestureDetector(onTap: goToToday)` → `CupertinoButton`
  - **`monthly_calendar_grid.dart`** 각 날짜 셀: `GestureDetector(onTap: selectDateFromMonthly)` → `CupertinoButton`
  - **교체 방법**: `CupertinoButton(minSize: 0, padding: EdgeInsets.zero, onPressed: ..., child: ...)`

- [ ] **15-3**: 현재 시간 캡슐 X축 위치 — 구분선에 딱 붙도록
  - **현재**: `right: 0` → 캡슐 오른쪽 = 시간 열 Stack 오른쪽 끝 → 구분선 왼쪽
  - **목표**: 캡슐이 구분선과 이어지도록 (1px 갭 제거)
  - **해결**: `right: -calendarDividerThickness` (= `right: -0.5`)
  - 파일: `current_time_indicator.dart` `CurrentTimeCapsule.build()` `Positioned(right: 0)` 수정

- [ ] **15-7**: 날짜 열 구분선 간헐적 틀어짐 수정
  - **원인**: `PageView(viewportFraction: 1/3)`에서 각 셀 너비가 fractional pixel
    → 셀마다 subpixel 반올림이 달라 `DecoratedBox(right border)` 위치가 1px씩 어긋남
  - **해결**: Stack Positioned 고정 오버레이 방식으로 재전환
    - `LayoutBuilder`로 `pageWidth = (maxWidth - timeColumnWidth - dividerThickness) / 3` 계산
    - 각 셀의 `DecoratedBox(right border)` 제거
    - `ThreeDayCalendar` Expanded → Stack으로 감싸고 Positioned 오버레이 2개 추가:
      - `Positioned(left: pageWidth, top: dividerTop, bottom: 0)` → 1번째 구분선
      - `Positioned(left: pageWidth * 2, top: dividerTop, bottom: 0)` → 2번째 구분선
    - `dividerTop = threeDayHeaderHeight(28) + calendarDividerThickness(0.5) + allDayRowHeight(40) + calendarDividerThickness(0.5)`
  - 파일: `three_day_calendar.dart`

- [ ] **15-5**: 월간 캘린더 선택 UI 2번 깜빡임 제거
  - **원인**: `AnimatedContainer`가 셀별 독립 동작 → 새 선택/기존 선택 각각 별개로 애니메이션
  - **해결**: `AnimatedContainer` → `Container` 복원 (즉시 변경)
  - 파일: `monthly_calendar_grid.dart`

- [ ] **15-2**: 점포 필터 버튼 아이콘 확인
  - 현재 이미 `CupertinoIcons.calendar_circle`로 복원됨 (확인만 필요)
  - 파일: `home_nav_bar.dart` `Icon(CupertinoIcons.calendar_circle, size: 24.0)`

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
- [ ] 바운싱 스크롤 복원 + 바운싱 후 스크롤 정상 동작 (15-1)
- [ ] GestureDetector → CupertinoButton 교체 (15-6)
- [ ] 현재 시간 캡슐과 구분선 사이 갭 제거 (15-3)
- [ ] 날짜 열 구분선 틀어짐 없음 (15-7)
- [ ] 월간 캘린더 선택 UI 깜빡임 없음 (15-5)
- [ ] 점포 필터 버튼 아이콘 확인 (15-2)
