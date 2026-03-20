# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-20 (3차)

## Phase 1~13: 완료 ✅

## Phase 14: 피드백 반영 7차 ✅ (완료 — 일부 추가 수정 필요, Phase 15로 이관)

- [x] **14-1**: 네비바 피커 → 점포 필터 버튼 (`CupertinoIcons.list_bullet`, placeholder 바텀시트) — 아이콘 재변경 필요 (15-2)
- [x] **14-2**: bouncing sync 복원 (try-catch + bouncing skip 제거) — 완전 해결 안됨 (15-1)
- [x] **14-3**: 시간 레이블 `FractionalTranslation(Offset(0,-0.5))` → 픽셀 추정 없이 정확한 중앙 정렬 ✅
- [x] **14-4**: `AnimatedContainer` 기본 `BoxDecoration(radius:8)` → 애니메이션 중 코너 유지 — 2번 깜빡임 추가 수정 필요 (15-5)
- [x] **14-5**: `_isAnimating` 플래그 → monthly calendar `onPageChanged` 중 중간값 방지 ✅ (하지만 3일 calendar animateToPage 중 monthly 중간 상태 버그 남음 → 15-4)
- [x] **14-6**: Stack Positioned 구분선 2개 제거 → 각 날짜 Column `DecoratedBox(right border)`. `LayoutBuilder` 제거 ✅
- [x] **14-7**: `CurrentTimeCapsule` `right: 0` → `right: 4` — 위치 아직 불일치 (15-3)

---

## Phase 15: 피드백 반영 8차 (다음 세션 구현 예정)

### 버그 수정 (우선순위 높음)

- [ ] **15-1**: bouncing 후 스크롤 불가 재발
  - 14-2에서 `try-catch` 추가했으나 여전히 bouncing 후 입력 차단 발생
  - **근본 원인**: bouncing 중 `jumpTo(음수 offset)`이 다른 컨트롤러를 불안정 상태로 만듦
  - **해결 방향 A** (권장): `BouncingScrollPhysics` → `ClampingScrollPhysics` 변경
    - bouncing 시각 효과 없어지지만 안정성 확보
    - iOS 앱이라 bouncing이 자연스럽다면 Option B
  - **해결 방향 B**: bouncing 중 sync 재차단 (`offset < 0 || offset > maxExtent`), bouncing 종료 감지 후 재동기화
    - `_scrollController.position.isScrollingNotifier` 또는 `ScrollNotification` 활용

- [ ] **15-4**: 월간 캘린더→3일 캘린더 animateToPage 중 monthly 캘린더 중간 달 표시 버그
  - **원인**: 3-day PageView `animateToPage` 중 `onPageChanged` → `selectDateFromSwipe(중간 날짜)` → `displayedMonth` 변경 → monthly 캘린더 jump
    - 예: Dec → Oct 선택 시 3-day가 animateToPage 하면서 Nov, Nov-x, Oct… 순서로 `selectDateFromSwipe` 호출
    - 이로 인해 monthly 캘린더가 12월→11월→10월 순으로 점프
  - **해결**: `_ThreeDayCalendarState`에 `_isPageAnimating` 플래그 추가
    - `animateToPage` 호출 시 `_isPageAnimating = true`
    - `.then((_) { if (mounted) _isPageAnimating = false; })`
    - `onPageChanged` 내: `if (_isPageAnimating)` → `selectDateFromSwipe` 건너뜀 (마지막 도착 페이지에서만 호출)
  - 파일: `three_day_calendar.dart` `ref.listen(selectedStartDate)` 블록 + `onPageChanged`
  - **주의**: `animateToPage` `.then()` 타이밍 이슈 — 도착 페이지에서는 `selectDateFromSwipe`가 반드시 호출되어야 함
    - 대안: `_isPageAnimating = false` 후 현재 page로 `selectDateFromSwipe` 수동 호출

- [ ] **15-2**: 점포 필터 버튼 아이콘 원복
  - `CupertinoIcons.list_bullet` → `CupertinoIcons.calendar_circle` (Phase 14 이전 아이콘)
  - 아이콘만 변경, 탭 동작(`_showStoreFilter`)은 유지
  - 파일: `home_nav_bar.dart` line ~67

### UI 수정

- [ ] **15-3**: 현재 시간 캡슐 X축 위치 재조정
  - `right: 4` 적용 후 오히려 너무 좌측, 구분선과 이어지지 않음
  - **목표**: 노션 캘린더처럼 캡슐이 시간 열과 날짜 열 구분선 위에 걸쳐 표시
  - **구조 문제**: `CurrentTimeCapsule`은 시간 열 Stack 내부 → `right: 0`이어도 시간 열 오른쪽 끝
    구분선(`calendarDividerThickness = 0.5px`)을 넘어 날짜 열로 못 나감
  - **해결 방향**: `CurrentTimeCapsule`을 시간 열 Stack 밖으로 꺼내어 `ThreeDayCalendar Row` 레벨에서 `Positioned`로 배치
    - 또는 시간 열 Stack의 `clipBehavior: Clip.none` + `right: -(capsuleWidth - timeColumnWidth)` 로 날짜 열 위로 overflow
    - 현재 Stack은 이미 `clipBehavior: Clip.none` 설정되어 있으므로 `right` 값 조정으로 가능
    - `right`가 음수면 Stack 오른쪽으로 overflow: `right: -(calendarDividerThickness)` (구분선 위에 걸치도록)
    - 또는 기존 `right: 0` 복원 후 오른쪽으로 살짝 튀어나오게: overflow 이용
  - 파일: `current_time_indicator.dart` `CurrentTimeCapsule.build()` Positioned

- [ ] **15-5**: 월간 캘린더 선택 UI 2번 깜빡임 제거
  - **현상**: 날짜 탭 시 새 선택 날짜에 먼저 애니메이션 발생 (1번), 이후 기존 선택에서 새 선택으로 애니메이션 (2번)
  - **원인**: `AnimatedContainer`가 셀별 독립 동작
    - 새 선택 셀: `BoxDecoration(radius:8, color:null)` → `BoxDecoration(radius:8, color:label)` (fade-in = 1번 깜빡임)
    - 기존 선택 셀: `BoxDecoration(radius:8, color:label)` → `BoxDecoration(radius:8, color:null)` (fade-out)
  - **해결 (권장)**: `AnimatedContainer` → `Container` 복원. 선택 UI 즉시 변경
    - 세련된 애니메이션은 추후 `AnimatedSwitcher` 또는 `CustomPainter` 방식으로 별도 구현
  - 파일: `monthly_calendar_grid.dart`

---

## 최종 검증 (Phase 15 완료 후 재검증)
- [x] 월간 캘린더 overflow 없이 접힘/펼침
- [x] 월간 캘린더 좌우 스와이프 월 이동
- [x] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [x] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅)
- [x] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [x] 네비바 animateToPage 중 중간값 없음 (`_isAnimating` ✅)
- [x] 날짜 열 구분선 날짜별 소유 (DecoratedBox right border ✅)
- [x] 시간 라벨 & 구분선 Y축 정렬 (`FractionalTranslation` ✅)
- [x] 오늘 날짜 UI 정상
- [x] 다크 모드 색상 정상
- [x] `dart analyze lib/` 에러 없음
- [ ] bouncing 시 전체 날짜 동기화 (15-1)
- [ ] 3일 캘린더 animateToPage 중 monthly 중간 상태 없음 (15-4)
- [ ] 점포 필터 버튼 아이콘 (15-2)
- [ ] 현재 시간 캡슐 구분선 위에 걸치도록 (15-3)
- [ ] 월간 캘린더 선택 UI 깜빡임 없음 (15-5)
