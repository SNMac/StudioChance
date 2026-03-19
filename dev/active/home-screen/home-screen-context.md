# 홈 화면 구현 - 컨텍스트

Last Updated: 2026-03-19

## 현재 구현 상태

Phase 1~11 완료. `dart analyze lib/` → No issues found.

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
| 종일 행 | `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` |
| 시간 그리드 | `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` |
| 현재시간 인디케이터 | `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` |
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
context.white              // 캡슐 텍스트, 오늘 날짜 숫자
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

---

## ThreeDayCalendar 구조

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
2. `selectedStartDate` → `jumpToPage()` (외부 날짜 변경 시)

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

// 피커: showModalBottomSheet(enableDrag: true) + Grabber 표시
//   - Grabber: Container(width:36, height:4, borderRadius:2, systemGrey3)
//   - StatefulBuilder + tempDate (완료 버튼에서만 selectDate 호출)
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
// → 분 경계에서 즉시 갱신됨
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

## TimeGrid 구조

```dart
GestureDetector(onScaleStart/Update: 핀치줌)
└── SingleChildScrollView(BouncingScrollPhysics, sharedScrollController)
    └── SizedBox(height: hourHeight * 24)
        └── Stack
            ├── SizedBox.expand()  // 배경 레이어
            ├── for hour in 1..23: Positioned(top: hourHeight*hour)
            │   └── Row[
            │       SizedBox(width: 44),  // 시간 레이블
            │       Transform.translate(0, -12): Align(topRight): Text("HH:00"),
            │       SizedBox(width: 1.5),
            │       Expanded(Divider(separator, 0.5))
            │   ]
            └── Positioned(top: CurrentTimeIndicator.topPosition(hourHeight))
                └── CurrentTimeIndicator(hourHeight)
```

열 사이 구분선은 ThreeDayCalendar Stack의 Positioned 오버레이에서 처리.
dividerTop = threeDayHeaderHeight(28) + 0.5

---

## 주의사항

### 월간 캘린더 높이 계산
- `monthlyCalendarHeight = 260` = 헤더 60px + 날짜 5행 200px
- 헤더가 SizedBox(height: 60)으로 고정되어야 전체 260px를 채움
- OverflowBox(maxHeight: 260)로 AnimatedContainer tight constraints 우회
- MonthlyCalendar Column의 mainAxisSize: min 제거 (default max 사용)

### ThreeDayCalendar - animateToPage vs jumpToPage
- 외부 날짜 변경(월간 캘린더 선택, 피커, 오늘 버튼): `jumpToPage` (즉시 이동)
- 사용자 스와이프: PageView가 자연스럽게 처리

### CurrentTimeIndicator 타이머
- 이전: `Timer.periodic(1분)` → 시작 시점 기준 1분 간격 (분 경계 불일치)
- 현재: 첫 Timer는 다음 정각까지 대기 후, 이후 1분 간격 Timer.periodic

### 코드 생성
ScrollToCurrentTimeTrigger 추가로 build_runner 재실행 완료.
HomeCalendarState 필드 변경 없음.

---

## 의존성
- `shared_preferences: ^2.5.4`
- `riverpod_generator`, `freezed`
- `flutter/cupertino.dart` (CupertinoIcons, CupertinoDatePicker)
- `dart:io` (Platform.isIOS)
