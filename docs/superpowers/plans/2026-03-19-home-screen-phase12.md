# 홈 화면 Phase 12 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈 화면 피드백 5차 반영 — 애니메이션 정책, 오늘 날짜 UI, 버튼 크기, 3일 캘린더 1일 단위 스크롤 + 시간 열 고정, CurrentTimeIndicator 개선.

**Architecture:** `ThreeDayCalendar`를 `viewportFraction: 1/3` (1페이지=1일) + 고정 시간 열 구조로 전면 재구성. 수직 스크롤은 페이지별 개별 ScrollController + 중앙 offset 동기화 패턴 사용. `CurrentTimeIndicator`를 캡슐(`CurrentTimeCapsule`)과 선(`CurrentTimeLine`)으로 분리. 나머지 항목(애니메이션, 월간 캘린더 UI, 버튼 크기)은 독립 수정.

**Tech Stack:** Flutter/Dart, Riverpod (riverpod_generator), Freezed, SharedPreferences

---

## 파일 변경 목록

| 파일 | 작업 |
|---|---|
| `lib/presentation/providers/home_calendar_controller.dart` | Task 1: CalendarTransitionKind enum + 플래그 + 메서드 추가 |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart` | Task 2: _syncPageToMonth 애니메이션 분기 |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | Task 7: 전체 구조 재작성 (애니메이션 분기 포함) |
| `lib/presentation/home/widgets/three_day_calendar/three_day_header.dart` | Task 7: 삭제 (ThreeDayCalendar 내부 위젯으로 통합됨) |
| `lib/presentation/home/widgets/home_nav_bar.dart` | Task 3: 피커 → selectDateFromPicker, 버튼 크기 24px |
| `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart` | Task 4: 오늘 날짜 3단계 UI |
| `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` | Task 5: CurrentTimeCapsule + CurrentTimeLine 분리, topPosition -6px |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | Task 6: 시간 레이블 제거, scrollController 필수화 |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` | Task 6: AllDayCell로 단순화 |

---

## Task 1: CalendarTransitionKind — 컨트롤러 애니메이션 플래그

**파일:** `lib/presentation/providers/home_calendar_controller.dart`

`HomeCalendarController`에 non-state 플래그 2개와 consume 패턴을 추가한다.
`selectDate()`, `goToToday()`, `selectDateFromSwipe()`, `selectDateFromPicker()` 메서드를 정비한다.

- [ ] **Step 1: CalendarTransitionKind enum 및 플래그 추가**

`home_calendar_controller.dart`에서 `part` 선언 아래에 enum을 추가하고, `HomeCalendarController` 클래스 안에 non-state 필드와 consume 메서드를 추가한다.

```dart
// part 선언 아래 추가
enum CalendarTransitionKind { jump, animate }
```

`HomeCalendarController` 클래스 내부 (기존 `build()` 위):

```dart
// 애니메이션 플래그 (상태 아님, 코드 생성 불필요)
CalendarTransitionKind _threeDayTransition = CalendarTransitionKind.jump;
CalendarTransitionKind _monthlyTransition = CalendarTransitionKind.jump;

/// 3일 캘린더 페이지 전환 종류를 소비하고 기본값(jump)으로 리셋
CalendarTransitionKind consumeThreeDayTransition() {
  final k = _threeDayTransition;
  _threeDayTransition = CalendarTransitionKind.jump;
  return k;
}

/// 월간 캘린더 페이지 전환 종류를 소비하고 기본값(jump)으로 리셋
CalendarTransitionKind consumeMonthlyTransition() {
  final k = _monthlyTransition;
  _monthlyTransition = CalendarTransitionKind.jump;
  return k;
}
```

- [ ] **Step 2: goToToday() 수정 — 두 플래그 모두 animate**

```dart
/// 오늘 날짜로 이동 (슬라이드 애니메이션) + 3일 캘린더 현재 시간으로 스크롤
void goToToday() {
  _threeDayTransition = CalendarTransitionKind.animate;
  _monthlyTransition = CalendarTransitionKind.animate;
  final now = DateTime.now();
  state = state.copyWith(
    selectedStartDate: DateTime(now.year, now.month, now.day),
    displayedMonth: DateTime(now.year, now.month, 1),
  );
  ref.read(scrollToCurrentTimeTriggerProvider.notifier).trigger();
}
```

- [ ] **Step 3: selectDateFromSwipe() 추가 — 3일 캘린더 onPageChanged 전용**

월 경계 통과 시에만 월간 캘린더를 animate로 이동.

```dart
/// 3일 캘린더 스와이프 시 날짜 이동 (ThreeDayCalendar.onPageChanged에서 호출)
/// 월 경계 통과 시 월간 캘린더 animateToPage
void selectDateFromSwipe(DateTime date) {
  final newStart = DateTime(date.year, date.month, date.day);
  final newMonth = DateTime(date.year, date.month, 1);
  if (newMonth != state.displayedMonth) {
    _monthlyTransition = CalendarTransitionKind.animate;
  }
  state = state.copyWith(
    selectedStartDate: newStart,
    displayedMonth: newMonth,
  );
}
```

- [ ] **Step 4: selectDateFromPicker() 추가 — 피커 전용**

```dart
/// 피커에서 날짜 확정 시 이동 (home_nav_bar.dart에서 호출)
/// 3일 캘린더 + 월간 캘린더 모두 animateToPage
void selectDateFromPicker(DateTime date) {
  _threeDayTransition = CalendarTransitionKind.animate;
  _monthlyTransition = CalendarTransitionKind.animate;
  selectDate(date);
}
```

- [ ] **Step 5: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/providers/home_calendar_controller.dart
```
Expected: No issues found.

- [ ] **Step 6: 커밋**

```bash
git add lib/presentation/providers/home_calendar_controller.dart
git commit -m "feat: #5 - CalendarTransitionKind 플래그 및 애니메이션 메서드 추가"
```

---

## Task 2: 애니메이션 정책 — MonthlyCalendar 연결

**파일:** `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart`

Task 1에서 만든 플래그를 월간 캘린더 PageView 이동에 연결한다.
ThreeDayCalendar는 Task 7에서 전면 재작성하므로 해당 수정은 Task 7에서 처리한다.

- [ ] **Step 1: MonthlyCalendar — _syncPageToMonth 애니메이션 분기**

`monthly_calendar.dart`의 `_syncPageToMonth` 메서드를 교체:

```dart
void _syncPageToMonth(DateTime month) {
  final totalMonths = month.year * 12 + (month.month - 1);
  final refTotalMonths =
      _referenceMonth.year * 12 + (_referenceMonth.month - 1);
  final targetPage = _initialPage + (totalMonths - refTotalMonths);
  if (!_pageController.hasClients ||
      _pageController.page?.round() == targetPage) return;
  final kind = ref
      .read(homeCalendarControllerProvider.notifier)
      .consumeMonthlyTransition();
  if (kind == CalendarTransitionKind.animate) {
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    _pageController.jumpToPage(targetPage);
  }
}
```

- [ ] **Step 2: CalendarTransitionKind import 확인**

`monthly_calendar.dart`는 `home_calendar_controller.dart`를 이미 import하고 있으므로 enum은 자동으로 접근 가능.

- [ ] **Step 3: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/home/widgets/monthly_calendar/
```
Expected: No issues found.

- [ ] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart
git commit -m "feat: #5 - 월간 캘린더 _syncPageToMonth 애니메이션 분기"
```

---

## Task 3: HomeNavBar — 피커 + 버튼 크기

**파일:** `lib/presentation/home/widgets/home_nav_bar.dart`

피커 완료 버튼에서 `selectDateFromPicker()` 호출로 변경, 버튼 크기 20→24px.

- [ ] **Step 1: 피커 완료 버튼 — selectDateFromPicker로 변경**

iOS 피커의 완료 버튼 `onPressed` (현재 `selectDate` 호출 부분):

```dart
onPressed: () {
  Navigator.pop(ctx);
  ref
      .read(homeCalendarControllerProvider.notifier)
      .selectDateFromPicker(tempDate);  // selectDate → selectDateFromPicker
},
```

Android `showDatePicker` then 콜백:

```dart
.then((date) {
  if (date != null) {
    ref
        .read(homeCalendarControllerProvider.notifier)
        .selectDateFromPicker(date);  // selectDate → selectDateFromPicker
  }
});
```

- [ ] **Step 2: 캘린더 피커 아이콘 크기 20 → 24**

```dart
Icon(
  CupertinoIcons.calendar_circle,
  size: 24.0,  // 20.0 → 24.0
  color: context.label,
),
```

- [ ] **Step 3: 오늘 날짜 버튼 원 크기 20 → 24**

```dart
Container(
  width: 24.0,   // 20.0 → 24.0
  height: 24.0,  // 20.0 → 24.0
  decoration: BoxDecoration(
    color: context.label,
    borderRadius: BorderRadius.circular(12.0),  // 10.0 → 12.0
  ),
  ...
),
```

- [ ] **Step 4: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/home/widgets/home_nav_bar.dart
```

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/home_nav_bar.dart
git commit -m "feat: #5 - 피커 애니메이션 연결, 네비바 버튼 크기 24px"
```

---

## Task 4: 월간 캘린더 오늘 날짜 UI

**파일:** `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart`

셀 렌더링 로직에 `isToday` 상태를 추가하여 3단계 UI를 구현한다.

- [ ] **Step 1: isToday 판별 추가**

`MonthlyCalendarGrid.build()` 안에서 `cellDate` 계산 후:

```dart
final today = DateTime.now();
final bool isToday = cellDate.year == today.year &&
    cellDate.month == today.month &&
    cellDate.day == today.day;
```

- [ ] **Step 2: 셀 decoration/색상 분기 로직 교체**

기존의 `if (isSelected1) { ... } else if (isSelected2 || isSelected3) { ... }` 블록을 아래로 교체:

```dart
BoxDecoration? decoration;
Color finalTextColor = textColor;
Widget? innerCircle;

if (isSelected1) {
  if (isToday) {
    // 오늘 & 선택: label 사각형 + systemBackground 원 + label 숫자
    decoration = BoxDecoration(
      color: context.label,
      borderRadius: BorderRadius.circular(8),
    );
    innerCircle = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.systemBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
          color: context.label,
        ),
      ),
    );
    finalTextColor = Colors.transparent; // innerCircle이 텍스트를 그림
  } else {
    // 일반 날짜 선택: label 사각형 + systemBackground 숫자
    decoration = BoxDecoration(
      color: context.label,
      borderRadius: BorderRadius.circular(8),
    );
    finalTextColor = context.systemBackground;
  }
} else if (isSelected2 || isSelected3) {
  decoration = BoxDecoration(
    color: context.secondarySystemFill,
    borderRadius: BorderRadius.circular(8),
  );
} else if (isToday) {
  // 오늘 & 미선택: label 원 + systemBackground 숫자
  innerCircle = Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: context.label,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      '$day',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 16,
        color: context.systemBackground,
      ),
    ),
  );
  finalTextColor = Colors.transparent; // innerCircle이 텍스트를 그림
}
```

- [ ] **Step 3: 셀 child 교체 — innerCircle 우선 렌더링**

```dart
child: Container(
  width: 40,
  height: 40,
  decoration: decoration ?? const BoxDecoration(),
  alignment: Alignment.center,
  child: innerCircle ??
      Text(
        '$day',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
          color: finalTextColor,
        ),
      ),
),
```

- [ ] **Step 4: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart
```

- [ ] **Step 5: 커밋**

```bash
git add lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart
git commit -m "feat: #5 - 월간 캘린더 오늘 날짜 3단계 UI (선택/미선택/일반)"
```

---

## Task 5: CurrentTimeIndicator 분리 + y축 수정

**파일:** `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart`

기존 `CurrentTimeIndicator`(캡슐+선 한 위젯)를 `CurrentTimeCapsule`과 `CurrentTimeLine`으로 분리한다.
`topPosition` 공식에 -6px 보정을 추가한다.

기존 파일을 완전히 재작성한다.

- [ ] **Step 1: current_time_indicator.dart 전체 재작성**

핵심 변경:
- 두 위젯 모두 `Positioned`를 직접 반환 → 타이머 rebuild 시 `top` 위치가 자동 갱신됨
- `_now` 필드 불필요: `build()` 내 `DateTime.now()` 호출로 항상 최신값 사용
- 타이머는 `setState(() {})` 만 호출 (rebuild 트리거용)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';

/// 현재 시간의 캡슐 top 위치 계산 (시간 레이블 중앙과 y축 정렬)
/// 시간 레이블: Transform.translate(0, -12) → 레이블 중앙 ≈ hourHeight*hour - 6
/// 보정값 6px을 빼서 캡슐 중앙을 레이블 중앙에 일치시킴
double currentTimeTopPosition(double hourHeight) {
  final now = DateTime.now();
  return hourHeight * (now.hour + now.minute / 60) -
      currentTimeCapsuleHeight / 2 -
      6;
}

/// 현재 시간 캡슐 위젯 (고정 시간 열 Stack의 직접 자식으로 배치)
/// Positioned를 직접 반환하므로 타이머 rebuild 시 top 위치가 자동 갱신됨
class CurrentTimeCapsule extends StatefulWidget {
  const CurrentTimeCapsule({super.key, required this.hourHeight});

  final double hourHeight;

  @override
  State<CurrentTimeCapsule> createState() => _CurrentTimeCapsuleState();
}

class _CurrentTimeCapsuleState extends State<CurrentTimeCapsule> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute)
            .add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Positioned(
      top: currentTimeTopPosition(widget.hourHeight),
      right: 0,
      child: Container(
        width: currentTimeCapsuleWidth,
        height: currentTimeCapsuleHeight,
        decoration: BoxDecoration(
          color: context.systemRed,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text(
          timeText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                height: 1.0,
                color: context.white,
              ),
        ),
      ),
    );
  }
}

/// 현재 시간 수평선 위젯 (날짜 열 event grid Stack의 직접 자식으로 배치)
/// Positioned를 직접 반환하므로 타이머 rebuild 시 top 위치가 자동 갱신됨
/// isToday: true → systemRed, false → systemRed 30% opacity
class CurrentTimeLine extends StatefulWidget {
  const CurrentTimeLine({
    super.key,
    required this.hourHeight,
    required this.isToday,
  });

  final double hourHeight;
  final bool isToday;

  @override
  State<CurrentTimeLine> createState() => _CurrentTimeLineState();
}

class _CurrentTimeLineState extends State<CurrentTimeLine> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  void _scheduleNextUpdate() {
    final now = DateTime.now();
    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute)
            .add(const Duration(minutes: 1));
    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 선의 top = 캡슐 top + capsuleHeight/2 (캡슐 중앙 = 선 y좌표)
    final top = currentTimeTopPosition(widget.hourHeight) +
        currentTimeCapsuleHeight / 2;
    final color = widget.isToday
        ? context.systemRed
        : context.systemRed.withValues(alpha: 0.3);
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Container(height: currentTimeLineThickness, color: color),
    );
  }
}
```

- [ ] **Step 2: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart
```

Expected: No issues found.
`CurrentTimeIndicator` 클래스가 사라지므로 이를 참조하는 파일들에서 오류가 발생할 수 있음. Task 6~7에서 해결.

- [ ] **Step 3: 커밋 (전체 analyze는 Task 7 이후)**

```bash
git add lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart
git commit -m "refactor: #5 - CurrentTimeCapsule + CurrentTimeLine으로 분리, topPosition -6px 보정"
```

---

## Task 6: TimeGrid 슬림화 + AllDayRow → AllDayCell

**파일:**
- `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`
- `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

`TimeGrid`에서 시간 레이블을 제거하고, scrollController를 필수화.
`AllDayRow`를 단순 빈 셀(`AllDayCell`)로 교체.

- [ ] **Step 1: time_grid.dart 재작성**

시간 레이블은 ThreeDayCalendar의 고정 시간 열로 이동하므로 TimeGrid에서 제거.
캡슐은 `CurrentTimeCapsule`로 분리되었으므로 제거.
수평 구분선과 `CurrentTimeLine`만 남김.
핀치 줌 `GestureDetector`는 ThreeDayCalendar로 이동.
`CurrentTimeLine`은 자체적으로 `Positioned`를 반환하므로 Stack의 직접 자식으로 배치.
`scrollController`는 항상 외부에서 주입받음 (필수 파라미터).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 날짜별 이벤트 그리드
/// 수평 시간 구분선과 현재 시간선을 표시, 수직 스크롤 지원
/// 핀치 줌은 ThreeDayCalendar에서 처리
class TimeGrid extends ConsumerWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
  });

  final ScrollController scrollController;

  /// 해당 날짜가 오늘인지 여부 (현재 시간선 색상 결정)
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );
    final totalHeight = hourHeight * 24;

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            const SizedBox.expand(),

            // 수평 시간 구분선 (1~23시)
            for (int hour = 1; hour < 24; hour++)
              Positioned(
                top: hourHeight * hour,
                left: 0,
                right: 0,
                child: Divider(
                  height: 0,
                  thickness: calendarDividerThickness,
                  color: context.separator,
                ),
              ),

            // 현재 시간선: CurrentTimeLine이 Positioned를 직접 반환
            CurrentTimeLine(hourHeight: hourHeight, isToday: isToday),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: all_day_row.dart 재작성 — AllDayCell로 단순화**

"종일" 레이블은 ThreeDayCalendar의 고정 시간 열로 이동.
내부 열 구분선은 ThreeDayCalendar Stack 오버레이로 이동.
이 파일은 빈 셀만 제공.

```dart
import 'package:flutter/material.dart';
import 'package:studio_chance/constants/ui_constants.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
/// 추후 종일 이벤트를 표시할 영역. 현재는 빈 상태.
class AllDayCell extends StatelessWidget {
  const AllDayCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: allDayRowHeight,
    );
  }
}
```

- [ ] **Step 3: dart analyze 통과 확인**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/
```

`AllDayRow` → `AllDayCell` 이름 변경으로 `three_day_calendar.dart`에서 오류 발생. Task 7에서 해결.

- [ ] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/time_grid.dart \
        lib/presentation/home/widgets/three_day_calendar/all_day_row.dart
git commit -m "refactor: #5 - TimeGrid 시간 레이블 제거, AllDayRow → AllDayCell 단순화"
```

---

## Task 7: ThreeDayCalendar 전체 구조 재작성

**파일:** `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

이 태스크가 Phase 12의 핵심. 전체를 재작성하므로 기존 파일 내용을 교체.

변경 요점:
- `PageController(viewportFraction: 1/3)` → 1페이지 = 1일
- 고정 시간 열 (`_TimeColumn` private 위젯): 시간 레이블 + 캡슐
- 날짜 열 영역 (`PageView`): 헤더 + AllDayCell + TimeGrid
- 수직 스크롤: `_dayScrollControllers` 맵 + `_syncAllScrollControllers`

- [ ] **Step 1: three_day_header.dart 파일 삭제**

`three_day_header.dart`의 `_DayHeaderCell` 로직은 `three_day_calendar.dart`에 인라인으로 통합된다.

```bash
git rm lib/presentation/home/widgets/three_day_calendar/three_day_header.dart
```

- [ ] **Step 2: three_day_calendar.dart 전체 재작성**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';

/// 3일 캘린더 최상위 위젯
/// - 좌측 고정 시간 열 (시간 레이블 + 현재 시간 캡슐)
/// - 우측 PageView (viewportFraction: 1/3, 1페이지=1일, 3일 동시 표시)
/// - 수직 스크롤: 페이지별 ScrollController + 중앙 offset 동기화
class ThreeDayCalendar extends ConsumerStatefulWidget {
  const ThreeDayCalendar({super.key});

  @override
  ConsumerState<ThreeDayCalendar> createState() => _ThreeDayCalendarState();
}

class _ThreeDayCalendarState extends ConsumerState<ThreeDayCalendar> {
  static const _initialPage = 10000;

  final _referenceDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  late final PageController _pageController;
  late final ScrollController _timeColumnScrollController;

  /// 현재 수직 스크롤 오프셋 (모든 날짜 열과 시간 열이 공유)
  double _currentVerticalOffset = 0.0;

  /// 재진입 방지 플래그 (_syncAllScrollControllers 무한 루프 방지)
  bool _isSyncing = false;

  /// 페이지 인덱스 → ScrollController 맵 (수직 스크롤 동기화)
  final Map<int, ScrollController> _dayScrollControllers = {};

  /// 핀치 줌 시작 시점의 hourHeight 기준값
  double _baseHourHeight = defaultHourHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 1 / 3,
    );
    _timeColumnScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timeColumnScrollController.dispose();
    for (final ctrl in _dayScrollControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  /// 페이지별 ScrollController 반환 (없으면 생성, 리스너 자동 등록)
  ScrollController _controllerForPage(int page) {
    return _dayScrollControllers.putIfAbsent(page, () {
      final ctrl = ScrollController(
        initialScrollOffset: _currentVerticalOffset,
      );
      ctrl.addListener(() {
        if (_isSyncing || !ctrl.hasClients) return;
        final offset = ctrl.offset;
        if (offset == _currentVerticalOffset) return;
        _currentVerticalOffset = offset;
        _syncAllScrollControllers(offset, except: ctrl);
      });
      return ctrl;
    });
  }

  /// 모든 날짜 열 + 시간 열 수직 스크롤 동기화 (재진입 방지)
  void _syncAllScrollControllers(double offset, {ScrollController? except}) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      for (final ctrl in _dayScrollControllers.values) {
        if (ctrl == except) continue;
        if (ctrl.hasClients && ctrl.offset != offset) ctrl.jumpTo(offset);
      }
      if (_timeColumnScrollController.hasClients &&
          _timeColumnScrollController.offset != offset) {
        _timeColumnScrollController.jumpTo(offset);
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// 현재 페이지 ±5 범위 밖의 ScrollController를 해제하여 메모리 누수 방지
  void _evictDistantControllers(int currentPage) {
    final toRemove = _dayScrollControllers.keys
        .where((page) => (page - currentPage).abs() > 5)
        .toList();
    for (final page in toRemove) {
      _dayScrollControllers.remove(page)?.dispose();
    }
  }

  /// 현재 시간이 뷰포트 중앙에 오도록 스크롤
  void _scrollToCurrentTime() {
    final hourHeight = ref.read(homeCalendarControllerProvider).hourHeight;
    final now = DateTime.now();
    final currentOffset = hourHeight * (now.hour + now.minute / 60);

    // 임의의 active controller로 viewportDimension 파악
    double viewportHeight = 600; // fallback
    for (final ctrl in _dayScrollControllers.values) {
      if (ctrl.hasClients) {
        viewportHeight = ctrl.position.viewportDimension;
        break;
      }
    }
    if (_timeColumnScrollController.hasClients) {
      viewportHeight =
          _timeColumnScrollController.position.viewportDimension;
    }

    final maxExtent = (hourHeight * 24 - viewportHeight).clamp(0.0, double.infinity);
    final target =
        (currentOffset - viewportHeight / 2).clamp(0.0, maxExtent);
    _currentVerticalOffset = target;
    _syncAllScrollControllers(target);
  }

  DateTime _dateForPage(int page) {
    return _referenceDate.add(Duration(days: page - _initialPage));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final hourHeight = ref.watch(
      homeCalendarControllerProvider.select((s) => s.hourHeight),
    );

    // 오늘 버튼 → 현재 시간 스크롤
    ref.listen(scrollToCurrentTimeTriggerProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentTime());
    });

    // 외부 날짜 변경 → PageView 동기화 (애니메이션 정책 분기)
    ref.listen(
      homeCalendarControllerProvider.select((s) => s.selectedStartDate),
      (prev, next) {
        if (prev == next) return;
        final delta = next.difference(_referenceDate).inDays;
        final targetPage = _initialPage + delta;
        if (!_pageController.hasClients ||
            _pageController.page?.round() == targetPage) return;
        final kind = ref
            .read(homeCalendarControllerProvider.notifier)
            .consumeThreeDayTransition();
        if (kind == CalendarTransitionKind.animate) {
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(targetPage);
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth / 3;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 고정 시간 열 ──────────────────────────────
            SizedBox(
              width: timeColumnWidth,
              child: Column(
                children: [
                  // 헤더 높이 공백
                  SizedBox(height: threeDayHeaderHeight),
                  Container(
                      height: calendarDividerThickness,
                      color: context.separator),
                  // "종일" 레이블
                  SizedBox(
                    height: allDayRowHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '종일',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: context.secondaryLabel,
                                ),
                      ),
                    ),
                  ),
                  Container(
                      height: calendarDividerThickness,
                      color: context.separator),
                  // 시간 레이블 + 캡슐 (수직 스크롤, 사용자 드래그 불가)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _timeColumnScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        height: hourHeight * 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 시간 레이블 (1~23시)
                            for (int hour = 1; hour < 24; hour++)
                              Positioned(
                                top: hourHeight * hour,
                                left: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: const Offset(0, -12),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4),
                                      child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: context.secondaryLabel,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // 현재 시간 캡슐: CurrentTimeCapsule이 Positioned를 직접 반환
                            CurrentTimeCapsule(hourHeight: hourHeight),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 시간열↔날짜열 구분선
            Container(width: calendarDividerThickness, color: context.separator),

            // ── 날짜 열 영역 ──────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      final newStart = _dateForPage(index);
                      _evictDistantControllers(index);
                      ref
                          .read(homeCalendarControllerProvider.notifier)
                          .selectDateFromSwipe(newStart);
                    },
                    itemBuilder: (context, index) {
                      final date = _dateForPage(index);
                      return Column(
                        children: [
                          // 요일/일자 헤더
                          SizedBox(
                            height: threeDayHeaderHeight,
                            child: _DayHeaderCell(date: date),
                          ),
                          Container(
                              height: calendarDividerThickness,
                              color: context.separator),
                          // 종일 이벤트 셀
                          const AllDayCell(),
                          Container(
                              height: calendarDividerThickness,
                              color: context.separator),
                          // 이벤트 그리드 (수직 스크롤)
                          // 핀치 줌: GestureDetector → ScaleGestureRecognizer(2손가락)와
                          //          PageScrollPhysics(1손가락)가 Flutter 제스처 아레나에서 자동 구분됨
                          Expanded(
                            child: GestureDetector(
                              onScaleStart: (_) {
                                _baseHourHeight = ref
                                    .read(homeCalendarControllerProvider)
                                    .hourHeight;
                              },
                              onScaleUpdate: (details) {
                                if (details.pointerCount < 2) return;
                                final oldHeight = ref
                                    .read(homeCalendarControllerProvider)
                                    .hourHeight;
                                final newHeight =
                                    (_baseHourHeight * details.scale)
                                        .clamp(minHourHeight, maxHourHeight);
                                // 스크롤 비율 보정: 확대/축소 후 뷰포트 중앙 위치 유지
                                if (oldHeight > 0 && newHeight != oldHeight) {
                                  // 뷰포트 높이 파악 (maxScrollExtent 계산에 사용)
                                  double viewportH = 600;
                                  if (_timeColumnScrollController.hasClients) {
                                    viewportH = _timeColumnScrollController
                                        .position.viewportDimension;
                                  }
                                  final rawOffset = _currentVerticalOffset *
                                      (newHeight / oldHeight);
                                  final maxOffset =
                                      (newHeight * 24 - viewportH)
                                          .clamp(0.0, double.infinity);
                                  final newOffset =
                                      rawOffset.clamp(0.0, maxOffset);
                                  _currentVerticalOffset = newOffset;
                                  _syncAllScrollControllers(newOffset);
                                }
                                // updateHourHeight는 Future<void> — unawaited로 fire-and-forget
                                unawaited(
                                  ref
                                      .read(homeCalendarControllerProvider
                                          .notifier)
                                      .updateHourHeight(newHeight),
                                );
                              },
                              child: TimeGrid(
                                scrollController: _controllerForPage(index),
                                isToday: _isToday(date),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // 날짜 열 사이 수직 구분선 (1일↔2일, 2일↔3일)
                  Positioned(
                    left: pageWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                        width: calendarDividerThickness,
                        color: context.separator),
                  ),
                  Positioned(
                    left: pageWidth * 2,
                    top: 0,
                    bottom: 0,
                    child: Container(
                        width: calendarDividerThickness,
                        color: context.separator),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── 헤더 셀 ────────────────────────────────────────────────────────────────

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({required this.date});

  final DateTime date;

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  String get _weekdayLabel => _weekdayLabels[date.weekday - 1];

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get _isSaturday => date.weekday == DateTime.saturday;
  bool get _isSunday => date.weekday == DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _weekdayLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _weekdayTextColor(context),
                ),
          ),
          const SizedBox(width: 4),
          _buildDayNumber(context),
        ],
      ),
    );
  }

  Color _weekdayTextColor(BuildContext context) {
    if (_isToday) return context.label;
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  Color _dayNumberColor(BuildContext context) {
    if (_isSaturday) return context.systemBlue;
    if (_isSunday) return context.systemRed;
    return context.secondaryLabel;
  }

  Widget _buildDayNumber(BuildContext context) {
    final dayText = date.day.toString();
    if (_isToday) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: context.label,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          dayText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.systemBackground,
              ),
        ),
      );
    }
    return Text(
      dayText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _dayNumberColor(context),
          ),
    );
  }
}
```

- [ ] **Step 3: dart analyze 전체 통과 확인**

```bash
dart analyze lib/
```

Expected: No issues found.

- [ ] **Step 4: 커밋**

```bash
git add lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
git rm lib/presentation/home/widgets/three_day_calendar/three_day_header.dart
git commit -m "feat: #5 - 3일 캘린더 1일 단위 스크롤 + 시간 열 고정 구조로 전환"
```

---

## Task 8: 최종 검증

- [ ] **Step 1: dart analyze 전체 통과**

```bash
dart analyze lib/
```

Expected: No issues found.

- [ ] **Step 2: 시뮬레이터/기기에서 동작 확인**

```bash
flutter run
```

확인 항목:
- [ ] 월간 캘린더 날짜 탭 → 3일 캘린더 즉시 이동 (애니메이션 없음)
- [ ] 오늘 버튼 → 3일 캘린더 슬라이드 + 월간 캘린더 슬라이드 + 현재 시간 스크롤
- [ ] 피커 완료 → 3일 캘린더 슬라이드 + 월간 캘린더 슬라이드
- [ ] 3일 캘린더 스와이프 월 경계 통과 → 월간 캘린더 슬라이드
- [ ] 월간 캘린더 오늘 날짜: 선택 시 label사각형+circle, 미선택 시 circle만
- [ ] 네비바 오늘 버튼 + 피커 아이콘 24px
- [ ] 3일 캘린더 스와이프 → 1일씩 이동, 빠른 스와이프 → 여러 날 이동
- [ ] 시간 열 고정 (좌우 스크롤 시 움직이지 않음)
- [ ] 수직 스크롤 시 시간 열 + 3개 날짜 열 동시 이동
- [ ] 핀치 줌 정상 동작
- [ ] 현재 시간 캡슐이 시간 레이블과 y축 정렬
- [ ] 오늘 날짜 열: 빨간 선, 다른 날짜 열: 30% 불투명 빨간 선
- [ ] 다크 모드 색상 정상

- [ ] **Step 3: dev-docs 업데이트**

```bash
# dev/active/home-screen/home-screen-tasks.md Phase 12 완료 표시
# dev/active/home-screen/home-screen-context.md 구조 업데이트
```

- [ ] **Step 4: 최종 커밋**

```bash
git add dev/active/home-screen/
git commit -m "chore: #5 - Phase 12 완료 dev-docs 업데이트"
```
