# 홈 화면 구현 - 컨텍스트

Last Updated: 2026-03-20 (3차 업데이트)

## 현재 구현 상태

Phase 1~14 완료 (일부 추가 수정 필요). `dart analyze lib/` → No issues found.
브랜치: `feat/#5-home`

---

## Phase 13 구현 내용 (이번 세션 완료)

### 핵심 변경 사항

**13-3: padEnds:false** (`three_day_calendar.dart`)
- `PageView.builder(padEnds: false)` → 현재 페이지가 뷰포트 왼쪽 첫 번째 열에 배치
- 오늘 날짜가 항상 왼쪽 첫 번째 열에 표시됨
- `PageController`가 아닌 `PageView.builder` 위젯에 속성 있음 (주의)

**13-4/5: currentTimeTopPosition 수정** (`current_time_indicator.dart`)
- 기존: `hourHeight * (h+m/60) - capsuleHeight/2 - 6` (6px 추가 보정)
- 변경: `hourHeight * (h+m/60) - capsuleHeight/2` (순수 중앙 정렬)
- 캡슐 중앙 = 정확한 현재 시간 위치, 구분선과 일치

**13-6: GestureDetector 이동** (`three_day_calendar.dart`)
- PageView 내 각 페이지 GestureDetector → LayoutBuilder 결과(Row 전체) 래핑
- 시간 열 포함 전체 영역에서 핀치 줌 인식

**13-7/8: 월간 캘린더 레이아웃** (`monthly_calendar.dart`, `ui_constants.dart`)
- `monthlyCalendarWeekdayRowHeight: 36 → 20`
- `Padding(all: 8)` + `Expanded` 구조로 변경 (날짜 그리드가 남은 공간 채움)
- `MonthlyCalendarGrid`의 5행 Column 각 Row를 `Expanded`로 감쌈 (균등 분배)

**13-9: selectDateFromMonthly** (`home_calendar_controller.dart`, `monthly_calendar_grid.dart`)
- 새 메서드: `_threeDayTransition = animate`만 설정 (월간 캘린더는 jump 유지)
- 월간 캘린더 탭 → 3일 캘린더 animateToPage

**13-10: 시간 레이블 translate** (`three_day_calendar.dart`)
- `Offset(0, -12)` → `Offset(0, -6)` (레이블 중앙이 구분선에 더 근접)
- 아직 완전한 정렬 미달 → Phase 14-3에서 추가 조정 필요

**13-2: bouncing sync** (`three_day_calendar.dart`)
- bouncing 범위(offset < 0 또는 > maxScrollExtent)에서 sync 건너뜀
- 결과: bouncing 후 입력 차단 해소, 그러나 하나의 날짜만 bounce 효과
- Phase 14-2에서 전체 bounce 동기화로 재수정 필요

**13-1: AnimatedContainer** (`monthly_calendar_grid.dart`)
- `Container` → `AnimatedContainer(duration: 200ms, curve: easeInOut)`
- 비선택 셀 `BoxDecoration()` → 선택 셀 `BoxDecoration(radius:8)` 보간 시 radius 중간값 = 0으로 보임
- Phase 14-4에서 기본 BoxDecoration에 radius 추가 필요

---

## Phase 14 피드백 (다음 세션 구현 예정)

## Phase 14 구현 내용 (이번 세션 완료)

### 14-1: 점포 필터 버튼
- `CupertinoIcons.calendar_circle` → `CupertinoIcons.list_bullet` (24×24, 오늘 버튼과 동일)
- `_showDatePicker` → `_showStoreFilter` (placeholder 바텀시트, 실제 데이터 미구현)
- ⚠️ 다음 세션에서 아이콘 `calendar_circle`로 원복 필요 (15-2)

### 14-2: bouncing sync 복원
- bouncing 범위 skip 제거, `jumpTo`에 `try-catch` 추가
- 결과: 여전히 bouncing 후 입력 차단 재발 → 15-1에서 근본 해결

### 14-3: 시간 레이블 Y축 정렬 ✅
- `Transform.translate(0,-6)` + `Align(topRight)` 구조 제거
- `FractionalTranslation(Offset(0, -0.5))` 도입 → 레이블 중앙이 정확히 `hourHeight * hour` (구분선 위치)와 일치
- 픽셀 추정 불필요, 폰트 크기 변경에도 자동 대응

### 14-4: AnimatedContainer 기본 radius
- 비선택 셀 `BoxDecoration()` → `BoxDecoration(borderRadius: BorderRadius.circular(8))`
- 애니메이션 중 코너 radius가 0으로 보이는 문제 해소
- 하지만 2번 깜빡임은 AnimatedContainer 구조적 한계 → 15-5에서 Container로 복원

### 14-5: _isAnimating 플래그 ✅
- `monthly_calendar.dart` `_MonthlyCalendarState`에 `_isAnimating: bool` 추가
- `animateToPage` 전 `true`, `.then((_) => _isAnimating = false)`
- `onPageChanged` 내: `if (_isAnimating) return;`
- 결과: 네비바 연/월이 중간 달을 표시하는 버그 해소
- 하지만 3-day `animateToPage` 중 `onPageChanged` → `selectDateFromSwipe` 문제는 별개 → 15-4

### 14-6: 날짜 열 구분선 구조 변경 ✅
- Stack Positioned 2개 제거 → 각 날짜 Column을 `DecoratedBox(right border)`로 래핑
- `LayoutBuilder` 완전 제거 (더 이상 `pageWidth` 불필요)
- bouncing 시 날짜 내용과 구분선이 함께 동작

### 14-7: 캡슐 right: 4
- `right: 0` → `right: 4` 적용
- 결과: 오히려 너무 좌측으로 이동, 구분선과 단절됨 → 15-3에서 재조정

---

## Phase 15 피드백 (다음 세션)

### 핵심 분석: 15-4 원인
`selectDateFromMonthly` 호출 시:
1. `_threeDayTransition = animate` 설정
2. `selectDate` → `displayedMonth = 목표 월` 즉시 변경
3. 3-day `animateToPage` 시작 (Dec→Oct 이동 시 페이지 여러 개 통과)
4. 각 페이지 통과마다 `onPageChanged` → `selectDateFromSwipe(중간 날짜)` → `displayedMonth = 중간 달`
5. monthly 캘린더 `ref.listen(displayedMonth)` → `jumpToPage(중간 달)` 연속 발생

**해결**: `_isPageAnimating` 플래그로 3-day animateToPage 중 `onPageChanged` 이벤트에서 `selectDateFromSwipe` 호출 차단

### 핵심 분석: 15-3 캡슐 위치
- 시간 열 Stack: `clipBehavior: Clip.none` 이미 설정됨
- `right: 0` → 캡슐 오른쪽이 시간 열 오른쪽 끝에 붙음 (= 구분선 왼쪽)
- `right: 4` → 캡슐이 더 왼쪽으로 들어감 (잘못된 방향)
- **정확한 위치**: 캡슐 왼쪽 = 시간 레이블 왼쪽, 캡슐 오른쪽 = 구분선 우측 살짝 넘어
  - `right: -(calendarDividerThickness)` 또는 `right: -1` 로 구분선 위에 살짝 걸치도록

---

## Phase 14 피드백 (구현 완료)

### 14-1. 네비바 버튼 기능 변경 (피처)
- 현재 "피커 버튼" → **점포 필터 버튼** (애플 캘린더의 "캘린더 선택"과 유사)
- 탭 시 사용자가 멤버로 있는 점포 목록 표시 → 어떤 점포 일정을 볼지 필터링
- 이 기능은 별도 데이터 연동이 필요한 피처 (점포/멤버 도메인)
- **시각적 크기 동일 확인**: 점포 필터 버튼 아이콘 크기 = 오늘 날짜 버튼 크기 (24×24, 터치 영역 제외 순수 시각 크기 기준)
  - `home_nav_bar.dart`에서 두 버튼 나란히 비교 확인

### 14-2. bouncing 전체 날짜 동기화
- 모든 날짜 열이 함께 bounce해야 함
- `_syncAllScrollControllers`에서 bouncing offset도 허용 (`try-catch` 방어)
- 관련 파일: `three_day_calendar.dart` `_controllerForPage` 내 listener + `_syncAllScrollControllers`

### 14-3. 시간 라벨 Y축 정렬 추가 조정
- `-6` 후에도 아직 라벨이 살짝 위에 있음
- `TextPainter`로 실제 렌더 높이 측정, 또는 `-5`, `-4` 값으로 시도

### 14-4. AnimatedContainer 선택 UI 수정
- **문제 1**: 새 선택 셀이 이전 셀보다 먼저 rebuild 발생 → 순서가 이상하게 보임
- **문제 2**: 비선택 셀 `BoxDecoration()` (radius=0)이 기본값이라 애니메이션 중 코너 없음
- **해결**: 모든 셀의 기본 `BoxDecoration(borderRadius: BorderRadius.circular(8))`로 통일

### 14-5. 네비바 연/월 animateToPage 중 중간값 표시 버그
- `monthly_calendar.dart`의 `onPageChanged`가 animateToPage 중 중간 페이지마다 호출됨
- `_isAnimating` 플래그로 중간 pageChanged 이벤트 무시
- animateToPage `.then((_) => _isAnimating = false)` + mounted 체크

### 14-6. 날짜 열 사이 구분선 구조 변경
- Stack Positioned → 각 날짜 Column의 오른쪽 Border로 이동
- `DecoratedBox(Border(right: BorderSide(0.5px, separator)))`로 Column 래핑
- Stack의 기존 2개 Positioned 구분선 제거

### 14-7. 현재 시간 캡슐 X축 위치 조정
- `Positioned(right: 0)` → `Positioned(right: 4)` (레이블 우측 패딩과 정렬)
- 파일: `three_day_calendar.dart` `CurrentTimeCapsule(hourHeight: hourHeight)` 아래 부분
  - 현재 직접 위젯 배치, `Positioned`는 `CurrentTimeCapsule` 내부에 있음 (`current_time_indicator.dart`)
  - `CurrentTimeCapsule.build()` 내 `Positioned(right: 0)` → `Positioned(right: 4)`

---

## Phase 13 피드백 (구현 완료)

2026-03-20 세션에서 수집된 피드백. 아직 구현 시작 전.

### 13-1. 월간 캘린더 선택 날짜 이동 애니메이션
- 3일 캘린더 스크롤 중 월간 캘린더 선택 UI가 딱딱하게 변함 → 부드러운 선택 UI 이동 애니메이션 필요

### 13-2. 맨 위/아래 bouncing 후 스크롤 불가 현상
- 3일 캘린더 상단/하단 bouncing 스크롤 후, 원래 크기로 줄어들 때까지 스크롤이 먹히지 않음
- `BouncingScrollPhysics` 관련 이슈로 추정

### 13-3. 오늘 날짜 초기 위치 오류
- 앱 시작 시 오늘 날짜가 3일 캘린더 가운데 열에 표시됨
- **오늘 날짜는 제일 왼쪽(첫 번째 열)에 위치해야 함**
- `_referenceDate` 또는 `initialPage` 계산 오류로 추정

### 13-4. 현재 시간 UI 위치 오류
- 예시: 2시 2분인데 2시 구분선보다 위에 표시됨
- `currentTimeTopPosition()` 계산 로직 재검토 필요
- `-6px` 보정값이 잘못된 것으로 의심 (`currentTimeCapsuleHeight / 2 = 6.5px`)

### 13-5. 현재 시간 캡슐 Y축 정렬 개선
- 현재 시간 캡슐과 시간 라벨의 Y축 정렬 아직 불일치
- **접근 방법**: 텍스트 라벨을 먼저 Y축 정렬시킨 후, 그 위에 캡슐을 씌우는 방식
- 캡슐 크기 조정 가능 (디자인 유사성 유지 전제)

### 13-6. 확대/축소 제스처 영역 확장
- 현재 핀치 줌이 3일 캘린더 날짜 표시 영역(PageView)에서만 작동하는지 확인 필요
- 좌측 시간 표시 영역(고정 열)에서도 인식되어야 함

### 13-7. 월간 캘린더 요일 헤더 높이 변경
- 현재 `monthlyCalendarWeekdayRowHeight = 36`
- **변경**: 요일 표시 UI 높이 = **20px**
- `monthlyCalendarWeekdayRowHeight` 상수 및 관련 레이아웃 업데이트 필요

### 13-8. 월간 캘린더 전체 높이 및 패딩 재설계
- 월간 캘린더 UI 전체 높이: **260px** (기존 유지)
- **실질적 캘린더 부분(날짜 그리드)**: 상하좌우 **8px 패딩** 추가
- 현재 패딩 없음 → `Padding(EdgeInsets.all(8))` 추가 필요

### 13-9. 월간 캘린더 날짜 선택 시 3일 캘린더 animateToPage
- 현재 `jumpToPage` (애니메이션 없음)
- **변경**: `animateToPage` (스크롤 애니메이션 적용)
- Phase 12-1에서 `jumpToPage`로 의도적으로 설정했던 것을 되돌림

### 13-10. 시간 라벨 X축 정렬 오류
- 3일 캘린더 시간 라벨과 일정 표시 영역 수평 구분선의 **X축 정렬 불일치**
- 시간 라벨이 구분선보다 살짝 위쪽으로 치우쳐 있음
- `Transform.translate(0, -12)` 값 재조정 필요
  - 구분선 위가 아니라 구분선과 수평 중앙 정렬이 목표

### 13-11. 현재 시간 선 날짜별 틀어짐
- `CurrentTimeLine`이 각 날짜 열에서 Y 위치가 서로 다르게 렌더링되는 현상
- 페이지별 `ScrollController` 오프셋 차이로 인한 것인지 확인 필요

### 13-12. 참고 앱
- **노션 캘린더(iOS)**: UI/UX 레퍼런스로 활용 중

---

## Phase 12 구현 내용 (이전 세션 완료)

### 핵심 아키텍처 변경

**3일 캘린더 구조 (`three_day_calendar.dart`)**:
- `PageController(viewportFraction: 1/3, initialPage: 10000)` — 1페이지=1일, 3일 동시 표시
- 좌측 고정 시간 열 (시간 레이블 1~23시 + `CurrentTimeCapsule`)
- 우측 PageView (날짜 헤더 + AllDayCell + TimeGrid)
- 수직 스크롤: `_dayScrollControllers: Map<int, ScrollController>` + `_syncAllScrollControllers` (`_isSyncing` 재진입 방지)
- 컨트롤러 eviction: `_evictDistantControllers(page)` — ±5 범위 밖 dispose
- 핀치 줌: ThreeDayCalendar 레벨 GestureDetector + scroll offset 비율 보정 + `unawaited(updateHourHeight(...))`
- `three_day_header.dart` 삭제 (`_DayHeaderCell` 인라인 통합)

**애니메이션 정책 (`home_calendar_controller.dart`)**:
- `CalendarTransitionKind` enum + `_threeDayTransition` / `_monthlyTransition` 필드 (non-state)
- `consumeThreeDayTransition()` / `consumeMonthlyTransition()` consume-and-reset 패턴
- `selectDateFromSwipe()` — 월 경계 통과 시만 monthly animate
- `selectDateFromPicker()` — 두 캘린더 모두 animate
- `goToToday()` — 두 캘린더 모두 animate

**CurrentTimeIndicator (`current_time_indicator.dart`)**:
- `CurrentTimeCapsule` / `CurrentTimeLine` 분리 (각각 `Positioned` 직접 반환)
- `currentTimeTopPosition()` — -6px 보정으로 시간 레이블 중앙과 y축 정렬
- `CurrentTimeLine` 모든 날짜 열에 렌더링: 오늘 systemRed, 비오늘 30% opacity

**AllDayRow → AllDayCell**: "종일" 레이블은 고정 시간 열로 이동, AllDayCell은 빈 SizedBox만

### 주요 설계 결정
- `pageWidth` 계산: `(constraints.maxWidth - timeColumnWidth - calendarDividerThickness) / 3` (날짜 열 구분선 위치 정확도)
- `viewportFraction: 1/3`에서 `PageScrollPhysics` → 1손가락 수평 스와이프 자동 처리
- `GestureDetector` ScaleGestureRecognizer(2손가락) vs PageScrollPhysics(1손가락) — Flutter 제스처 아레나에서 자동 구분

---

## 핵심 파일 경로

| 역할 | 경로 |
|------|------|
| 홈 화면 | `lib/presentation/home/screens/home_screen.dart` |
| 홈 캘린더 컨트롤러 | `lib/presentation/providers/home_calendar_controller.dart` |
| hourHeight 저장 | `lib/presentation/providers/hour_height_preference_provider.dart` |
| 네비게이션 바 | `lib/presentation/home/widgets/home_nav_bar.dart` |
| 하단 탭바 | `lib/presentation/home/widgets/home_tab_bar.dart` |
| 월간 캘린더 (PageView) | `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart` |
| 월간 캘린더 헤더 | `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_header.dart` |
| 월간 캘린더 그리드 | `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart` |
| 3일 캘린더 (PageView 전체) | `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` |
| 종일 이벤트 셀 | `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` (`AllDayCell`) |
| 시간 그리드 | `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` |
| 현재시간 캡슐+선 | `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` (`CurrentTimeCapsule`, `CurrentTimeLine`) |
| 색상 Extension | `lib/presentation/commons/extensions/context_colors.dart` |
| UI 상수 | `lib/constants/ui_constants.dart` |

---

## 색상 시스템

`context_colors.dart`의 Extension 사용:

```dart
context.label              // 주 텍스트
context.secondaryLabel     // 보조 텍스트
context.systemBackground   // 배경
context.separator          // 구분선
context.secondarySystemFill // 선택 셀 배경 (월간 캘린더 2,3번째 선택일)
context.systemRed          // 일요일, 현재 시간선
context.systemBlue         // 토요일, 탭바 선택색
context.white              // 캡슐 텍스트
```

---

## UI 상수 (ui_constants.dart)

```dart
const double homeNavBarHeight = 44.0;
const double timeColumnWidth = 44.0;
const double allDayRowHeight = 40.0;
const double defaultHourHeight = 36.0;
const double minHourHeight = 18.0;
const double maxHourHeight = 72.0;
const double calendarDividerThickness = 0.5;
const double currentTimeLineThickness = 1.0;
const double currentTimeCapsuleWidth = 32.0;
const double currentTimeCapsuleHeight = 13.0;
const double monthlyCalendarDayRowHeight = 40.0;
const double monthlyCalendarWeekdayRowHeight = 36.0;
const double monthlyCalendarHeight = 260.0;  // 헤더(60) + 날짜5행(200)
const double threeDayHeaderHeight = 28.0;
const double tabBarHeight = 49.0;
```

---

## HomeScreen 구조

```
Scaffold
├── body: SafeArea(bottom:false)
│   └── Column
│       ├── HomeNavBar (Platform.isIOS ? 44 : kToolbarHeight)
│       ├── AnimatedContainer(height: 0 or 260, Clip.hardEdge)
│       │   └── OverflowBox(maxHeight: 260, alignment: topCenter)
│       │       └── MonthlyCalendar (260px 채움)
│       └── Expanded
│           └── ThreeDayCalendar (ConsumerStatefulWidget)
└── bottomNavigationBar: HomeTabBar (height: 49 + SafeArea.bottom)
```

---

## MonthlyCalendar 구조

```
ColoredBox(systemBackground)
└── Column
    ├── SizedBox(height: 60)  ← monthlyCalendarHeight - dayRowHeight*5
    │   └── MonthlyCalendarHeader (일~토 요일 헤더)
    └── SizedBox(height: 200)  ← monthlyCalendarDayRowHeight * 5
        └── PageView.builder (initialPage=10000, 월 단위 스냅)
            └── MonthlyCalendarGrid(displayedMonth, selectedStartDate)
```

### MonthlyCalendar ref.listen 목록
1. `displayedMonth` → `_syncPageToMonth()` (jumpToPage, 애니메이션 없음)
2. `isMonthlyCalendarVisible` → true로 바뀔 때 postFrameCallback으로 `_syncPageToMonth()`

**이유**: 월간 캘린더가 숨겨진 상태(height=0)에서는 `jumpToPage`가 실패할 수 있으므로,
열릴 때 한번 더 동기화.

**Phase 12-1 이후**: `_syncPageToMonth()`도 소스에 따라 `animateToPage` vs `jumpToPage` 분기 필요

---

## ThreeDayCalendar 구조 (현재 - Phase 12-4/5 이전)

```
ConsumerStatefulWidget
├── _pageController (PageController, initialPage=10000)
├── _sharedScrollController (ScrollController, 페이지 간 수직 위치 공유)
└── build():
    LayoutBuilder
    └── Stack
        ├── PageView.builder (PageScrollPhysics, 1일 스냅)
        │   └── Column (per page)
        │       ├── SizedBox(height: 28)  ← threeDayHeaderHeight
        │       │   └── _ThreeDayHeaderPage(startDate)
        │       ├── Divider(height: 0.5, separator)
        │       ├── AllDayRow (height: 40)
        │       └── Expanded(TimeGrid(scrollController: _sharedScrollController))
        ├── Positioned(시간열↔날짜열 구분선, top: dividerTop, bottom: 0)
        ├── Positioned(1번째↔2번째 열 구분선)
        └── Positioned(2번째↔3번째 열 구분선)
```

### ThreeDayCalendar ref.listen 목록
1. `scrollToCurrentTimeTriggerProvider` → `_scrollToCurrentTime()` (오늘 버튼)
2. `selectedStartDate` → `jumpToPage()` (외부 날짜 변경 시 - Phase 12-1에서 소스 분기 예정)

### ThreeDayCalendar 주요 메서드
- `_scrollToCurrentTime()`: 현재 시간이 뷰포트 중앙에 오도록 스크롤 (animateTo)
- `_dateForPage(int)`: 페이지 인덱스 → DateTime 변환
- `_referenceDate`: 앱 시작 시 기준 날짜 (시간 제거)

---

## HomeCalendarState 구조

```dart
@freezed
abstract class HomeCalendarState with _$HomeCalendarState {
  const factory HomeCalendarState({
    required DateTime selectedStartDate,  // 3일 캘린더 첫째 날
    required bool isMonthlyCalendarVisible,
    required double hourHeight,           // 시간 행 높이 (핀치줌)
    required DateTime displayedMonth,     // 네비바 연월 표시 (day=1 고정)
  }) = _HomeCalendarState;
}
```

### HomeCalendarController 메서드
- `selectDate(DateTime)` → selectedStartDate + displayedMonth 업데이트
- `toggleMonthlyCalendar()` → isMonthlyCalendarVisible 토글
- `updateHourHeight(double)` → 핀치줌 + SharedPreferences 저장
- `goToToday()` → 오늘로 이동 + scrollToCurrentTimeTrigger.trigger() 호출
- `setDisplayedMonth(DateTime)` → 월간 캘린더 PageView onPageChanged에서 호출

### scrollToCurrentTimeTriggerProvider
```dart
@riverpod
class ScrollToCurrentTimeTrigger extends _$ScrollToCurrentTimeTrigger {
  @override
  int build() => 0;
  void trigger() => state = state + 1;
}
```
- `goToToday()`에서 `ref.read(...).trigger()` 호출
- ThreeDayCalendar에서 `ref.listen(scrollToCurrentTimeTriggerProvider, ...)`으로 감지

---

## HomeNavBar 구조

```dart
// 좌측: 연월 텍스트 + chevron (크기 12×7, 간격 8)
_ChevronIcon(isUp: bool, color: Color)  // CustomPaint로 구현
  → _ChevronPainter: strokeWidth 1.5, 두 직선으로 V/∧ 그림

// 우측 버튼 (Phase 12-3 이후: 모두 24×24, 터치영역 44×44)
// 피커: showModalBottomSheet(enableDrag: true) + Grabber 표시
//   - Grabber: Container(width:36, height:4, borderRadius:2, systemGrey3)
//   - StatefulBuilder + tempDate (완료 버튼에서만 selectDate 호출)
// 오늘 버튼: 원형(24×24) + 오늘 날짜 숫자
```

---

## CurrentTimeIndicator 핵심 로직

```dart
// topPosition: 캡슐이 시간 레이블과 수직 정렬되도록 capsuleHeight/2 위로 이동
static double topPosition(double hourHeight) {
  final now = DateTime.now();
  return hourHeight * (now.hour + now.minute / 60) - currentTimeCapsuleHeight / 2;
}

// 타이머: 다음 분 정각에 맞춰 첫 번째 Timer 설정 후 1분 간격 반복
void _scheduleNextUpdate() {
  final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute)
      .add(const Duration(minutes: 1));
  final delay = nextMinute.difference(now);
  _timer = Timer(delay, () {
    setState(() => _now = DateTime.now());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  });
}
```

---

## TimeGrid 구조 (현재)

```dart
GestureDetector(onScaleStart/Update: 핀치줌)
└── SingleChildScrollView(BouncingScrollPhysics, sharedScrollController)
    └── SizedBox(height: hourHeight * 24)
        └── Stack
            ├── SizedBox.expand()  // 배경 레이어
            ├── for hour in 1..23: Positioned(top: hourHeight*hour)
            │   └── Row[
            │       SizedBox(width: 44),  // 시간 레이블 (Phase 12-5에서 외부로 이동)
            │       Transform.translate(0, -12): Align(topRight): Text("HH:00"),
            │       SizedBox(width: 1.5),
            │       Expanded(Divider(separator, 0.5))
            │   ]
            └── Positioned(top: CurrentTimeIndicator.topPosition(hourHeight))
                └── CurrentTimeIndicator(hourHeight)
```

열 사이 구분선은 ThreeDayCalendar Stack의 Positioned 오버레이에서 처리.
dividerTop = threeDayHeaderHeight(28) + 0.5

**Phase 12-5 이후**: 시간 레이블은 TimeGrid 외부 고정 영역으로 이동, 구분선도 날짜 열 내부로 재구성

---

## 주의사항

### 월간 캘린더 높이 계산
- `monthlyCalendarHeight = 260` = 헤더 60px + 날짜 5행 200px
- 헤더가 SizedBox(height: 60)으로 고정되어야 전체 260px를 채움
- OverflowBox(maxHeight: 260)로 AnimatedContainer tight constraints 우회
- MonthlyCalendar Column의 mainAxisSize: min 제거 (default max 사용)

### ThreeDayCalendar - animateToPage vs jumpToPage (Phase 12-1 이후 변경 예정)
- 현재: 모든 외부 날짜 변경 시 `jumpToPage`
- 목표:
  - 월간 캘린더 날짜 선택: `jumpToPage`
  - 오늘 버튼 / 피커 / 3일 캘린더 스크롤 중 월 경계: `animateToPage`

### CurrentTimeIndicator 타이머
- 이전: `Timer.periodic(1분)` → 시작 시점 기준 1분 간격 (분 경계 불일치)
- 현재: 첫 Timer는 다음 정각까지 대기 후, 이후 1분 간격 Timer.periodic

### 코드 생성
ScrollToCurrentTimeTrigger 추가로 build_runner 재실행 완료.
Phase 12에서 `DateChangeSource` enum 등 추가 시 `dart run build_runner build --delete-conflicting-outputs` 재실행 필요.

---

## 의존성
- `shared_preferences: ^2.5.4`
- `riverpod_generator`, `freezed`
- `flutter/cupertino.dart` (CupertinoIcons, CupertinoDatePicker)
- `dart:io` (Platform.isIOS)
