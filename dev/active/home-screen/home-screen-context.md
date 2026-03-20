# 홈 화면 구현 - 컨텍스트

Last Updated: 2026-03-20 (4차 업데이트)

## 현재 구현 상태

Phase 1~15-4 완료. `dart analyze lib/` → No issues found.
브랜치: `feat/#5-home`

---

## Phase 15 신규 발견 사항 (2026-03-20 세션)

### 캘린더 날짜 범위
- **지원 범위: 2001.01.01 ~ 2100.12.31**
- `PageView initialPage=10000`, `_referenceDate = today`
- 10000 days offset ≈ 27년 → 2001~2100 범위를 커버하려면 초기화 방식 재검토 필요
  - 현재 `_referenceDate = today (2026년)` 기준, page 0 = today - 10000일 ≈ 1999년
  - 실제로는 10000 이내 범위만 접근 가능하므로 문제없음 (2001~2100은 약 ±37000일이라 page 초과)
  - **TODO**: `_initialPage`를 더 큰 값으로 늘리거나, `_referenceDate`를 2001.01.01로 고정하는 방식 검토 필요
  - 현재 세션에서는 미구현, Phase 16 과제로 이관

### 시간 레이블 Y축 정렬 (사용자 직접 수정 완료)
- 사용자가 직접 `three_day_calendar.dart` 시간 레이블 위치 조정
- 현재 `FractionalTranslation(Offset(0, -0.5))` 적용 → 시간 레이블 중앙 = 구분선 y좌표
- 현재 시간 캡슐(`CurrentTimeCapsule`)과 y축 정렬 ✅
- **추가 발견**: 현재 시간 캡슐 오른쪽 끝과 날짜 열 구분선 사이에 약 1px 갭이 존재
  - 원인: `CurrentTimeCapsule`의 `right: 0` = 시간 열 Stack 오른쪽 끝
  - 시간 열↔날짜 열 구분선 (`Container(width: 0.5)`)이 그 오른쪽에 위치
  - 캡슐이 구분선에 이어지려면 `right: -calendarDividerThickness` (= `right: -0.5`) 필요
  - 파일: `current_time_indicator.dart` `CurrentTimeCapsule.build()` → `Positioned(right: 0)`

### 바운싱 스크롤 복원 필요 (15-1 재정의)
- 현재 상태: `time_grid.dart`에 `ClampingScrollPhysics()` 적용됨 → **바운싱이 완전히 사라짐**
- 이전 15-1 해결 방향 A(ClampingScrollPhysics)가 적용되었으나, 사용자가 바운싱 복원 요청
- **목표**: iOS 자연스러운 바운싱은 살리되, 바운싱 후 스크롤 불가 현상만 제거
- **해결 방향 재정의**:
  - `ClampingScrollPhysics` → `BouncingScrollPhysics`로 복원
  - `_controllerForPage` 리스너에서 bouncing 중 sync 차단:
    ```dart
    ctrl.addListener(() {
      if (_isSyncing || !ctrl.hasClients) return;
      final offset = ctrl.offset;
      // bouncing 범위에서는 sync 건너뜀 (다른 컨트롤러를 불안정 상태로 만드는 원인)
      final maxExtent = ctrl.position.maxScrollExtent;
      if (offset < 0 || offset > maxExtent) return;
      if (offset == _currentVerticalOffset) return;
      _currentVerticalOffset = offset;
      _syncAllScrollControllers(offset, except: ctrl);
    });
    ```
  - 바운싱 종료 후 재동기화: `ScrollEndNotification` 또는 position.isScrollingNotifier 활용
  - 파일: `three_day_calendar.dart` `_controllerForPage` 리스너 + `time_grid.dart` physics

### GestureDetector → CupertinoButton 교체 (신규 태스크)
- **`home_nav_bar.dart`**: 3곳 모두 GestureDetector 사용 중
  1. 좌측 연월+chevron 버튼 (`onTap: notifier.toggleMonthlyCalendar`)
  2. 점포 필터 버튼 (`onTap: () => _showStoreFilter(context)`)
  3. 오늘 날짜 원형 버튼 (`onTap: notifier.goToToday`)
- **`monthly_calendar_grid.dart`**: 각 날짜 셀 GestureDetector (`onTap: selectDateFromMonthly`)
- **교체 방법**: `CupertinoButton(padding: EdgeInsets.zero, onPressed: ...)` 사용
  - 터치 영역은 기존 SizedBox(44×44) 또는 Expanded로 유지
  - `minSize: 0` 옵션으로 flutter 기본 최소 터치 영역 강제 방지
  - nav bar 버튼들: `CupertinoButton(minSize: 0, padding: EdgeInsets.zero, ...)`

### 날짜 열 구분선 틀어짐 원인 분석 (신규 태스크)
- **현상**: 날짜 열 사이 구분선 위치가 간헐적으로 틀어짐
- **원인 추정**: Phase 14-6에서 각 날짜 셀 `DecoratedBox(right border)` 방식 적용
  - `PageView(viewportFraction: 1/3)`에서 각 페이지 너비 = viewport / 3
  - 뷰포트 너비가 3으로 나누어 떨어지지 않으면 각 셀 너비가 fractional pixel
  - 브라우저/Flutter 렌더러의 subpixel 반올림이 셀마다 달라 border 위치가 1px씩 어긋남
- **해결 방향**: Stack Positioned 오버레이 방식으로 재복원 (Phase 14-6 이전 상태로 복원이 아닌, 개선된 방식)
  - `ThreeDayCalendar Row` 레벨에서 고정 위치 오버레이로 구분선 배치
  - 구분선 X위치 = `timeColumnWidth + calendarDividerThickness + pageWidth * n` (n=1,2)
  - `pageWidth` 계산은 `LayoutBuilder`로 `(constraints.maxWidth - timeColumnWidth - calendarDividerThickness) / 3`
  - 각 날짜 셀의 `DecoratedBox(right border)` 제거

---

## Phase 14 구현 내용 (완료)

### 14-1: 점포 필터 버튼
- `CupertinoIcons.calendar_circle` (15-2에서 list_bullet으로 변경했다가 다시 calendar_circle로 복원됨)
- `_showStoreFilter` placeholder 바텀시트 적용

### 14-2: bouncing sync 복원
- try-catch 추가, bouncing skip 제거
- 결과: 완전 해결 안됨 → 15-1 재정의 (ClampingScrollPhysics 적용, 이후 복원 필요)

### 14-3: 시간 레이블 Y축 정렬 ✅
- `FractionalTranslation(Offset(0, -0.5))` → 레이블 중앙 = 구분선 y좌표

### 14-4: AnimatedContainer 기본 radius ✅
- 비선택 셀 `BoxDecoration(borderRadius: BorderRadius.circular(8))`
- 2번 깜빡임 → 15-5에서 Container로 복원 예정

### 14-5: _isAnimating 플래그 ✅
- monthly_calendar.dart PageView animateToPage 중 중간값 방지

### 14-6: 날짜 열 구분선 구조 변경
- Stack Positioned 2개 → 각 날짜 Column `DecoratedBox(right border)`, `LayoutBuilder` 제거
- 간헐적 틀어짐 발생 → 15-7에서 재수정

### 14-7: 캡슐 right: 4 (이후 원복)
- 오히려 너무 좌측 → `right: 0`으로 다시 복원
- 15-3에서 `right: -0.5` 로 재조정 예정

---

## Phase 15 구현 내용 (진행 중)

### 15-4: _isPageAnimating 플래그 ✅
- `three_day_calendar.dart`에 `_isPageAnimating: bool` 추가
- `animateToPage` 호출 시 true, `.then()` 후 false + 도착 페이지 `selectDateFromSwipe` 수동 호출
- monthly 캘린더가 중간 달을 표시하는 버그 해소

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
| 현재시간 캡슐+선 | `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` |
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
const double monthlyCalendarWeekdayRowHeight = 20.0;  // Phase 13-7에서 36→20 변경
const double monthlyCalendarHeight = 260.0;
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
    │   └── MonthlyCalendarHeader (일~토 요일 헤더, height: 20)
    └── SizedBox(height: 200)  ← monthlyCalendarDayRowHeight * 5
        └── PageView.builder (initialPage=10000, 월 단위 스냅)
            └── MonthlyCalendarGrid(displayedMonth, selectedStartDate)
                └── Column (5 Expanded rows × 7 Expanded cols)
                    └── Padding(all: 8) → 날짜 그리드 영역
```

### MonthlyCalendar ref.listen 목록
1. `displayedMonth` → `_syncPageToMonth()` (animateToPage or jumpToPage, `_isAnimating` 플래그로 중간값 방지)
2. `isMonthlyCalendarVisible` → true로 바뀔 때 postFrameCallback으로 `_syncPageToMonth()`

---

## ThreeDayCalendar 구조 (현재)

```
ConsumerStatefulWidget (_ThreeDayCalendarState)
├── _pageController (PageController, viewportFraction: 1/3, initialPage: 10000)
├── _timeColumnScrollController (ScrollController, NeverScrollableScrollPhysics)
├── _dayScrollControllers: Map<int, ScrollController> (페이지별)
├── _currentVerticalOffset: double (공유 수직 오프셋)
├── _isSyncing: bool (sync 재진입 방지)
├── _isPageAnimating: bool (animateToPage 중 onPageChanged 차단)
└── build():
    GestureDetector (핀치 줌)
    └── Row
        ├── SizedBox(width: 44)  ← 고정 시간 열
        │   └── Column
        │       ├── SizedBox(height: 28)  ← threeDayHeaderHeight 공백
        │       ├── Container(height: 0.5, separator)
        │       ├── SizedBox(height: 40) "종일" 레이블
        │       ├── Container(height: 0.5, separator)
        │       └── Expanded → SingleChildScrollView(NeverScrollable)
        │           └── SizedBox(hourHeight*24)
        │               └── Stack(clipBehavior: Clip.none)
        │                   ├── for hour 1~23: Positioned(top: hourHeight*hour, right: 2)
        │                   │   └── FractionalTranslation(0, -0.5) → Text("HH:00")
        │                   └── CurrentTimeCapsule(hourHeight)  ← Positioned(right:0) 직접 반환
        ├── Container(width: 0.5, separator)  ← 시간열↔날짜열 구분선
        └── Expanded → Stack
            └── PageView.builder(padEnds: false)
                └── DecoratedBox(Border(right: 0.5, separator))  ← 각 셀 오른쪽 구분선
                    └── Column
                        ├── SizedBox(height: 28) → _DayHeaderCell
                        ├── Container(height: 0.5)
                        ├── AllDayCell
                        ├── Container(height: 0.5)
                        └── Expanded → TimeGrid(scrollController, isToday)
```

---

## HomeCalendarState 구조

```dart
@freezed
abstract class HomeCalendarState with _$HomeCalendarState {
  const factory HomeCalendarState({
    required DateTime selectedStartDate,
    required bool isMonthlyCalendarVisible,
    required double hourHeight,
    required DateTime displayedMonth,
  }) = _HomeCalendarState;
}
```

### HomeCalendarController 메서드
- `selectDate(DateTime)` → selectedStartDate + displayedMonth 업데이트
- `selectDateFromSwipe(DateTime)` → 월 경계 통과 시만 monthly animate
- `selectDateFromMonthly(DateTime)` → 3일 캘린더 animate, monthly jump
- `toggleMonthlyCalendar()` → isMonthlyCalendarVisible 토글
- `updateHourHeight(double)` → 핀치줌 + SharedPreferences 저장
- `goToToday()` → 오늘로 이동 + scrollToCurrentTimeTrigger.trigger() 호출
- `setDisplayedMonth(DateTime)` → 월간 캘린더 PageView onPageChanged에서 호출
- `consumeThreeDayTransition()` / `consumeMonthlyTransition()` → consume-and-reset 패턴

---

## 주의사항

### 캘린더 날짜 범위
- 지원 범위: **2001.01.01 ~ 2100.12.31**
- 현재 `initialPage=10000`, `_referenceDate=today` → 최대 ±10000일 접근 가능 (약 27년 범위)
- 전체 지원 범위를 커버하려면 `initialPage` 값을 크게 늘리거나 `_referenceDate`를 고정 날짜로 설정 필요
- Phase 16 과제

### BouncingScrollPhysics vs ClampingScrollPhysics
- Phase 15-1에서 ClampingScrollPhysics 적용 (바운싱 제거)
- **사용자 요청**: 바운싱 복원 필요 → BouncingScrollPhysics + bouncing 중 sync 차단으로 해결
- 파일: `time_grid.dart` `SingleChildScrollView.physics` + `three_day_calendar.dart` `_controllerForPage` 리스너

### 날짜 열 구분선 (Phase 14-6 이후)
- 각 날짜 셀 `DecoratedBox(right border)` 방식 → subpixel 반올림으로 간헐적 틀어짐
- 해결: Stack Positioned 고정 오버레이 방식으로 재전환 (LayoutBuilder 재도입)
- Phase 15-7 과제

### CupertinoButton 교체
- `home_nav_bar.dart` 3곳 GestureDetector → CupertinoButton
- `monthly_calendar_grid.dart` 날짜 셀 GestureDetector → CupertinoButton
- Phase 15-6 과제

### CurrentTimeCapsule과 구분선 연결
- `right: 0` → 캡슐 오른쪽 = 시간 열 Stack 오른쪽 끝 (구분선 왼쪽)
- `right: -0.5` (= `-calendarDividerThickness`) → 구분선과 딱 붙음
- 파일: `current_time_indicator.dart` `CurrentTimeCapsule.build()` `Positioned(right: ...)`
- Phase 15-3 과제

---

## 의존성
- `shared_preferences: ^2.5.4`
- `riverpod_generator`, `freezed`
- `flutter/cupertino.dart` (CupertinoIcons, CupertinoButton)
- `dart:io` (Platform.isIOS)
