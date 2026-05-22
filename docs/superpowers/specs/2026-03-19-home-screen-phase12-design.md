# 홈 화면 Phase 12 설계 문서

Date: 2026-03-19

## 개요

홈 화면 피드백 반영 5차. 6개 항목을 수정한다.

---

## 12-1: 애니메이션 정책 수정

### 문제
Phase 11-1에서 모든 페이지 이동을 `jumpToPage`로 교체했으나, 일부 케이스에는 슬라이드 애니메이션이 필요하다.

### 정책

| 액션 | ThreeDayCalendar | MonthlyCalendar |
|---|---|---|
| 월간 그리드 날짜 탭 | jumpToPage | jumpToPage |
| 오늘 버튼 | animateToPage | animateToPage |
| 피커 날짜 확정 | animateToPage | animateToPage |
| 3일 캘린더 스와이프 | PageView 자체 처리 | 월 경계 통과 시 animateToPage |

### 구현

`HomeCalendarController`에 non-state 플래그 2개 추가:

```dart
enum CalendarTransitionKind { jump, animate }

// notifier 내부 필드 (상태 아님, 코드 생성 불필요)
CalendarTransitionKind _threeDayTransition = CalendarTransitionKind.jump;
CalendarTransitionKind _monthlyTransition = CalendarTransitionKind.jump;

CalendarTransitionKind consumeThreeDayTransition() {
  final k = _threeDayTransition;
  _threeDayTransition = CalendarTransitionKind.jump; // 소비 후 기본값으로 리셋
  return k;
}

CalendarTransitionKind consumeMonthlyTransition() {
  final k = _monthlyTransition;
  _monthlyTransition = CalendarTransitionKind.jump;
  return k;
}
```

메서드 변경:
- `selectDate()` → 기존 유지 (월간 그리드 탭에서 호출, 플래그 미설정 = jump)
- `selectDateFromSwipe(date)` 추가 → 3일 캘린더 `onPageChanged`에서 호출
  - 월 경계 통과 판별: `DateTime(date.year, date.month, 1) != state.displayedMonth`일 때 `_monthlyTransition = animate`
- `selectDateFromPicker(date)` 추가 → 피커 완료 버튼에서 호출 (`home_nav_bar.dart`)
  - 두 플래그 모두 `animate` 설정 후 `selectDate()` 내부 로직 실행
- `goToToday()` 수정 → 두 플래그 모두 `animate` 설정 후 상태 변경

`ThreeDayCalendar` `selectedStartDate` 리스너에서 `consumeThreeDayTransition()` 결과에 따라 분기.
`MonthlyCalendar._syncPageToMonth()`에서 `consumeMonthlyTransition()` 결과에 따라 분기.

`animateToPage` 파라미터: `duration: Duration(milliseconds: 300)`, `curve: Curves.easeInOut`

---

## 12-2: 월간 캘린더 오늘 날짜 UI

### 3가지 상태

```
오늘 & 선택됨:
  [label색 borderRadius(8) 배경 40×40]
    └── [systemBackground 원 24×24]
          └── [label색 숫자]

오늘 & 미선택:
  [label색 원 24×24]
    └── [systemBackground 숫자]

일반 날짜 선택됨 (기존 유지):
  [label색 borderRadius(8) 배경 40×40]
    └── [systemBackground 숫자]
```

### 수정 위치
`monthly_calendar_grid.dart` — 셀 렌더링 로직 (오늘 날짜 판별 추가)

오늘 날짜 판별:
```dart
final today = DateTime.now();
final bool isToday = cellDate.year == today.year &&
    cellDate.month == today.month &&
    cellDate.day == today.day;
```

---

## 12-3: 네비바 버튼 크기 통일

오늘 날짜 버튼과 캘린더 피커 버튼의 아이콘/원형 크기를 `20 → 24px`으로 통일.
터치 영역(SizedBox 44×navBarHeight)은 변경 없음.

수정 위치: `home_nav_bar.dart`

---

## 12-4 + 12-5: 3일 캘린더 구조 변경

### 핵심 변경

**PageController**: `viewportFraction: 1/3` 적용. 1페이지 = 1일. 화면에 3일이 동시에 표시됨.

**레이아웃**: 시간 열을 PageView 외부 고정 영역으로 분리.

### 수직 스크롤 동기화 전략

`viewportFraction: 1/3`에서는 3개 이상의 페이지가 동시에 렌더링된다. 단일 `ScrollController`를 여러 `SingleChildScrollView`에 공유하면, 프로그래밍적 `jumpTo`는 모든 position에 전파되지만, 사용자의 드래그 스크롤은 해당 position만 업데이트한다. 따라서 **페이지별 개별 ScrollController + 중앙 offset 동기화** 방식을 사용한다.

```dart
// 현재 수직 스크롤 위치 (정보)
double _currentVerticalOffset = 0.0;

// 페이지 인덱스 → ScrollController 맵
final Map<int, ScrollController> _dayScrollControllers = {};

ScrollController _controllerForPage(int page) {
  return _dayScrollControllers.putIfAbsent(page, () {
    final ctrl = ScrollController(
      initialScrollOffset: _currentVerticalOffset,
    );
    ctrl.addListener(() {
      if (!ctrl.hasClients) return;
      final offset = ctrl.offset;
      if (offset == _currentVerticalOffset) return;
      _currentVerticalOffset = offset;
      _syncAllScrollControllers(offset, except: ctrl);
    });
    return ctrl;
  });
}

void _syncAllScrollControllers(double offset, {ScrollController? except}) {
  for (final ctrl in _dayScrollControllers.values) {
    if (ctrl == except) continue;
    if (ctrl.hasClients && ctrl.offset != offset) ctrl.jumpTo(offset);
  }
  if (_timeColumnScrollController.hasClients &&
      _timeColumnScrollController.offset != offset) {
    _timeColumnScrollController.jumpTo(offset);
  }
}
```

`_scrollToCurrentTime()` 수정: `_syncAllScrollControllers(target)` 호출.
핀치 줌 시 `updateHourHeight` 후 `_syncAllScrollControllers(newOffset)` 호출.

### 새 구조

```
ThreeDayCalendar
└── Row
    ├── 고정 시간 열 (width: timeColumnWidth = 44)
    │   └── Column
    │       ├── SizedBox(height: threeDayHeaderHeight = 28)  // 헤더 공백
    │       ├── Container(height: 0.5, color: separator)     // 수평 구분선
    │       ├── SizedBox(height: allDayRowHeight = 40)        // "종일" 레이블
    │       ├── Container(height: 0.5, color: separator)     // 수평 구분선
    │       └── Expanded
    │           └── SingleChildScrollView(
    │                 controller: _timeColumnScrollController,
    │                 physics: NeverScrollableScrollPhysics())
    │               └── SizedBox(height: 24 * hourHeight)
    │                   └── Stack: 시간 레이블 23개 (Positioned) + 캡슐
    └── Container(width: 0.5, color: separator)  // 시간열↔날짜열 구분선
    └── Expanded
        └── Stack
            ├── PageView(
            │     controller: _pageController,  // viewportFraction: 1/3
            │     physics: PageScrollPhysics())
            │   └── 1일 페이지:
            │       Column
            │       ├── SizedBox(height: 28): DayHeaderCell(date)
            │       ├── Container(height: 0.5, separator)
            │       ├── SizedBox(height: 40): AllDayCell (종일 이벤트만, 레이블 없음)
            │       ├── Container(height: 0.5, separator)
            │       └── Expanded
            │           └── GestureDetector(onScaleStart/Update: 핀치줌)
            │               └── SingleChildScrollView(
            │                     controller: _controllerForPage(index),
            │                     physics: BouncingScrollPhysics())
            │                   └── SizedBox(height: 24 * hourHeight)
            │                       └── Stack: 수평 구분선 23개 + TimeLine (오늘만)
            └── LayoutBuilder → Positioned 수직 구분선 2개
                  left: pageWidth * 1 (1일↔2일)
                  left: pageWidth * 2 (2일↔3일)
                  (pageWidth = constraints.maxWidth / 3)
```

### PageController 변경

```dart
// 변경 전
_pageController = PageController(initialPage: _initialPage);

// 변경 후
_pageController = PageController(
  initialPage: _initialPage,
  viewportFraction: 1 / 3,
);
```

### 날짜 계산

`_dateForPage(page)`: 기존 로직 유지. `page` = 1일에 대응.
`selectedStartDate` = 현재 스냅된 페이지의 날짜 (= 3일 중 좌측 날짜).

### CurrentTimeIndicator 분리

`CurrentTimeIndicator`를 두 개의 위젯으로 분리:

- `CurrentTimeCapsule`: 타이머 로직 보유, 시간 열 `SingleChildScrollView` Stack에 배치.
  `Positioned(top: topPosition, left: 0, right: 0)`
- `CurrentTimeLine`: 모든 날짜 페이지에 렌더링. event grid Stack에 배치.
  `Positioned(top: topPosition + capsuleHeight/2, left: 0, right: 0)`
  (top에 `capsuleHeight/2` 더해 캡슐 중앙 = 선 y좌표로 맞춤)
  - 오늘 날짜 페이지: `systemRed` (불투명도 100%)
  - 오늘 날짜가 아닌 페이지: `systemRed.withValues(alpha: 0.3)` (불투명도 30%)

두 위젯 모두 같은 `topPosition` 공식 사용. 타이머는 `CurrentTimeCapsule`에만 있고, `CurrentTimeLine`은 외부에서 현재 시간을 받거나 동일 타이머 로직을 보유.

실용적 구현: `CurrentTimeIndicator`는 그대로 두고, 캡슐+선을 각각 별도 `static` 메서드로 빌드하거나, `showLine: bool` 파라미터 추가로 분기.

### 핀치 줌 처리

`GestureDetector(onScaleStart/Update)`는 각 날짜 페이지의 `Expanded` 영역 안에 배치.
`PageScrollPhysics`(1손가락 수평 스와이프)와 `ScaleGestureRecognizer`(2손가락 핀치)는 Flutter 제스처 아레나에서 자동으로 구분된다. 현재 구현과 동일한 방식으로 충돌 없음.

### AllDayRow 변경

기존 `AllDayRow` 위젯: "종일" 레이블 + 3열 구분선을 자체 포함.
새 구조에서는 "종일" 레이블은 고정 시간 열에, 3열 AllDay 셀은 PageView 각 페이지에 배치.
`AllDayRow`는 단순 빈 셀 위젯(`AllDayCell`)으로 변경하거나, `AllDayRow`를 삭제하고 각 페이지 Column에 직접 배치.

### dispose

`_dayScrollControllers.values.forEach((c) => c.dispose())` in `dispose()`.
`_timeColumnScrollController.dispose()` in `dispose()`.

### 초기 스크롤

`ThreeDayCalendar.initState`의 `postFrameCallback`에서 `_scrollToCurrentTime()` 호출.
`_scrollToCurrentTime()`은 offset 계산 후 `_syncAllScrollControllers(target)` 호출.

---

## 12-6: CurrentTimeIndicator y축 정렬

### 문제

시간 레이블은 `Transform.translate(0, -12)`로 구분선 12px 위에 표시됨. labelSmall 폰트(10px) 높이 ≈ 12px이므로 레이블 중앙 = `hourHeight * hour - 6`. 캡슐 중앙은 `hourHeight * hour`. 약 6px 불일치.

### 수정

```dart
// current_time_indicator.dart
static double topPosition(double hourHeight) {
  final now = DateTime.now();
  // 6px 추가 보정으로 시간 레이블 중앙과 캡슐 중앙 일치
  return hourHeight * (now.hour + now.minute / 60)
      - currentTimeCapsuleHeight / 2
      - 6;
}
```

---

## 영향받는 파일

| 파일 | 변경 내용 |
|---|---|
| `lib/presentation/providers/home_calendar_controller.dart` | 12-1: enum, 플래그, 메서드 추가 |
| `lib/presentation/home/widgets/home_nav_bar.dart` | 12-1(피커), 12-3: 버튼 크기 |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart` | 12-1: _syncPageToMonth 분기 |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart` | 12-2: 오늘 날짜 UI |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | 12-1, 12-4, 12-5: 전체 구조 변경 |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | 12-5: 시간 레이블 제거, 구분선 유지 |
| `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` | 12-5, 12-6: 캡슐/선 분리, topPosition 수정 |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` | 12-5: 구조 변경에 따른 조정 |

## 코드 생성

`CalendarTransitionKind` enum은 일반 Dart enum으로 코드 생성 불필요.
`HomeCalendarState` freezed 구조 변경 없음.
`build_runner` 재실행 불필요.
