# 홈 화면 구현 - 컨텍스트

Last Updated: 2026-03-21 (9차 업데이트)

## 현재 구현 상태

Phase 1~19 완료. `dart analyze lib/` → No issues found.
브랜치: `feat/#5-home`

### 최근 수정 (Phase 19, 2026-03-21)

- **19-1 (Critical)**: 수직 스크롤 위치 어긋남 근본 원인 수정
  - `_controllerForPage`에 `isInitialized` flag 추가
  - attach 전 listener가 stale offset으로 `_currentVerticalOffset` 덮어쓰는 것 방지
  - postFrameCallback에서 `isInitialized = true` 설정 + 정확한 offset으로 교정

- **19-2**: 수직 구분선(시간열↔날짜열) 렌더링 방식 변경
  - Row-level `SizedBox(width: 0.5)` 완전 제거
  - GestureDetector child → Stack으로 교체
  - `Positioned(left: 44, top: 28.5, bottom: 0, width: 0.5)` overlay로 항상 최상단 렌더링

- **19-3**: 현재 시간선 left 값 조정
  - `currentTimeCapsuleRightInset = 0.25` 상수 추가 (ui_constants.dart)
  - `CurrentTimeCapsule.right` → `currentTimeCapsuleRightInset` 사용
  - `CurrentTimeLine.left` → `-currentTimeCapsuleRightInset` (= -0.25) 로 캡슐 끝과 일치
  - `TimeGrid` Stack: `clipBehavior: Clip.none` 추가

### 최근 수정 (Phase 18, 2026-03-20)

- **18-1**: 시간열↔날짜열 수직 구분선 → Row 레벨 SizedBox 컬럼 방식으로 복원
- **18-2**: 날짜 열 right border → Stack+Positioned(top: 28.5px) 방식으로 교체
- **18-3**: `_scrollToCurrentTimePending` 플래그 추가 → animateToPage 중 scrollToCurrentTime 예약 후 완료 시 실행
- **18-4 (중요)**: `_dateForPage` 및 `targetPage` 공식 버그 수정 (Phase 17-4 누락)
  - `_dateForPage(page)`: `_referenceDate.add(Duration(days: page - _initialPage))` → `_referenceDate.add(Duration(days: page))`
  - `targetPage`: `_initialPage + delta` → `next.difference(_referenceDate).inDays`
  - 이 버그로 앱 시작 시 2001-01-01 표시, 오늘 버튼이 2051년경 페이지로 이동했었음

---

## Phase 18 신규 발견 사항 (2026-03-20 세션)

### 18-1: 시간열↔날짜열 수직 구분선 시작 위치 재수정 (17-2 이어서)

**현상**: 수직 구분선이 종일(allday) 영역 안쪽에서 시작해야 하는데, 종일 영역 바깥(아래)부터 시작 중.

**원인**: Phase 17-2에서 구분선을 시간 열 Expanded 내부의 시간 그리드 Stack 안에 넣음
→ 시간 열 Column 구조: `[헤더(28px) | 헤더구분선(0.5px) | 종일(40px) | 종일구분선(0.5px) | Expanded(시간그리드)]`
→ 구분선이 Expanded(시간그리드) 내부에 있으므로 종일 영역 **아래**부터 시작됨

**해결**:
- 시간 그리드 Stack에서 구분선 Positioned 제거
- Row 레벨에 `SizedBox(width: 0.5, child: Column([헤더 공백, Expanded(ColoredBox)]))` 형태로 복원
- 헤더(28px) + 헤더구분선(0.5px) 만큼 공백 → 그 아래(종일 행 시작점)부터 구분선 렌더링
```dart
SizedBox(
  width: calendarDividerThickness,
  child: Column(
    children: [
      SizedBox(height: threeDayHeaderHeight + calendarDividerThickness),
      Expanded(child: ColoredBox(color: context.separator)),
    ],
  ),
),
```
- 파일: `three_day_calendar.dart` (Row 안, 시간 열 SizedBox 다음)

### 18-2: 날짜 열 구분선(DecoratedBox right border)이 요일 헤더 영역에도 표시

**현상**: 날짜 열 사이 구분선이 요일/날짜 헤더 행 안쪽까지 이어져 있음. 헤더 행 아래부터 시작해야 함.

**원인**: `DecoratedBox(border: Border(right: ...))` 가 Column 전체를 래핑 → 헤더 포함 전체 높이에 border 렌더링.

**해결**: `DecoratedBox` 제거 → `Stack + Positioned` 방식으로 교체
```dart
return Stack(
  children: [
    Column(
      children: [
        SizedBox(height: threeDayHeaderHeight, child: _DayHeaderCell(date: date)),
        Container(height: calendarDividerThickness, color: separator),
        const AllDayCell(),
        Container(height: calendarDividerThickness, color: separator),
        Expanded(child: TimeGrid(...)),
      ],
    ),
    // 헤더(28px) + 헤더구분선(0.5px) 이후부터 구분선 시작
    Positioned(
      top: threeDayHeaderHeight + calendarDividerThickness,
      bottom: 0,
      right: 0,
      child: Container(width: calendarDividerThickness, color: context.separator),
    ),
  ],
);
```
- **주의**: `Expanded`는 `Column`의 직접 자식이어야 하므로 `DecoratedBox`로 래핑하면 안 됨 → Stack 방식 필수
- 파일: `three_day_calendar.dart` `itemBuilder`

### 18-3: 좌우 스크롤 시 새 날짜의 수직 스크롤 위치가 이전 날짜와 다를 수 있음

**현상**: 오늘 날짜 버튼을 누른 뒤 스크롤을 살짝 올리고 다음 날짜로 이동하면, 다음 날짜는 살짝 올린 스크롤이 반영되지 않음.

**원인 분석**:
`goToToday()` 흐름:
1. `selectDate(today)` → `selectedStartDate` 변경 → `_pageController.animateToPage(todayPage, duration: 300ms)` 시작 (animate 트랜지션 정책)
2. `scrollToCurrentTimeTrigger.trigger()` → `ref.listen` → `addPostFrameCallback(_scrollToCurrentTime)`
3. 다음 프레임에 `_scrollToCurrentTime()` 실행 → **이 시점에 `animateToPage(300ms)` 가 아직 진행 중**
4. `_syncAllScrollControllers(target)` 가 animateToPage 도중에 실행 → 인접 페이지 컨트롤러들이 target으로 동기화됨
5. animateToPage 완료 → 일부 컨트롤러가 animation 과정에서 다른 위치로 이동됨
6. 이후 사용자가 스크롤 살짝 → `_currentVerticalOffset` 업데이트 → 이미 `hasClients`가 false이거나 다른 상태인 컨트롤러에 sync가 제대로 전달 안 됨

**해결 방향**: `_scrollToCurrentTime` 호출 타이밍을 animateToPage 완료 이후로 이동
- `scrollToCurrentTimeTrigger` listen에서 `addPostFrameCallback` 대신, `animateToPage.then()` 내부에서 호출
- 단, animateToPage를 쓰지 않는 경우(jumpToPage)에도 동작해야 함 → 조건 분기
- 또는: `_scrollToCurrentTime`에 실행 지연 추가(animateToPage 300ms 이후)

**더 근본적 해결**: `scrollToCurrentTimeTrigger` listen을 `addPostFrameCallback` 방식에서 벗어나, `animateToPage` 완료 시점과 명시적으로 동기화
```dart
// selectedStartDate listen 블록 내:
if (kind == CalendarTransitionKind.animate) {
  _isPageAnimating = true;
  _pageController.animateToPage(...).then((_) {
    if (mounted) {
      _isPageAnimating = false;
      ref.read(...).selectDateFromSwipe(_dateForPage(targetPage));
      _scrollToCurrentTime(); // ← animateToPage 완료 후 실행
    }
  });
}
```
- `scrollToCurrentTimeTrigger` listen은 유지하되, goToToday 경우는 animateToPage.then()에서 처리
- 파일: `three_day_calendar.dart` `ref.listen(selectedStartDate)` 블록 + `ref.listen(scrollToCurrentTimeTrigger)` 블록

---

## Phase 17 신규 발견 사항 (2026-03-20 세션)

### 17-1: 날짜 열 구분선 좌우 스크롤 시 고정 문제

**현상**: 3일 캘린더 좌우 스크롤 시 날짜 열 사이 구분선이 움직이지 않고 고정되어 있음.

**원인**: Phase 15-7에서 `DecoratedBox(right border)` 방식 → `LayoutBuilder + Stack Positioned 오버레이` 방식으로 변경했는데, Positioned 오버레이는 Stack 안에 고정 위치이므로 PageView 스크롤과 무관하게 항상 같은 자리에 렌더링됨.

**해결 방향**: Phase 15-7을 되돌려 `DecoratedBox(right border)` 방식으로 복원.
- 각 날짜 셀의 Column을 `DecoratedBox(decoration: BoxDecoration(border: Border(right: BorderSide(color: separator, width: calendarDividerThickness))))` 로 래핑
- `LayoutBuilder` 제거 (pageWidth 계산 불필요)
- Positioned 오버레이 2개 제거
- 원래 있던 fractional pixel 문제는 실제로 체감하기 어려운 수준이었으므로, 이 방식이 더 낫다고 판단
- 파일: `three_day_calendar.dart` (itemBuilder 부분 + Positioned 오버레이 제거)

**주의**: `LayoutBuilder`를 제거하면 `pageWidth`와 `dividerTop`이 없어지므로, 해당 변수에 의존하는 코드도 함께 제거.

### 17-2: 시간열↔날짜열 수직 구분선이 요일 헤더 영역까지 침범

**현상**: 좌측 시간 표시 열과 우측 날짜 열 사이의 수직 구분선(0.5px)이 요일/날짜 헤더 영역에도 표시됨. 종일 영역부터 시작되어야 함.

**원인**: 현재 구조:
```dart
Row([
  SizedBox(width: 44),          // 시간 열
  Container(width: 0.5),        // ← 이 구분선이 Row 전체 높이(헤더 포함)에 걸쳐 렌더링
  Expanded(child: PageView),    // 날짜 열
])
```
`Container(width: 0.5)`는 Row의 cross axis 방향으로 최대한 늘어남 → 헤더부터 바닥까지 전체 높이.

**해결**:
```dart
SizedBox(
  width: calendarDividerThickness,
  child: Column(
    children: [
      // 헤더 영역 + 헤더 구분선: 빈 공간
      SizedBox(height: threeDayHeaderHeight + calendarDividerThickness),
      // 종일 영역부터 바닥까지: 실제 구분선
      Expanded(child: ColoredBox(color: context.separator)),
    ],
  ),
),
```
- 파일: `three_day_calendar.dart` `Container(width: calendarDividerThickness, ...)` 부분

### 17-3: 현재 시간 캡슐이 시간열↔날짜열 구분선에 잘림

**현상**: 현재 시간 캡슐 오른쪽 끝이 시간열↔날짜열 구분선에 가려져 보임.

**원인**:
- 캡슐은 시간 열 Stack 안의 `Positioned(right: -calendarDividerThickness)` → Stack 오른쪽 끝 밖으로 0.5px 삐져나옴
- Row 렌더링 순서: 시간 열(1번) → 구분선(2번) → 날짜 열(3번)
- Flutter Row는 순서대로 페인트 → 구분선(2번)이 시간 열(1번) overflow 위에 덧칠됨
- 결과: 캡슐 오른쪽 0.5px가 구분선에 덮임 + 시각적으로 잘린 느낌

**해결 방향**:
- `right: -calendarDividerThickness` → `right: -(calendarDividerThickness + 2)` 또는 `right: -2`
- 캡슐이 구분선을 2px 이상 넘어 날짜 열로 돌출 → 구분선에 가려지지 않음
- 단, 구분선이 캡슐 위에 계속 렌더링되므로 캡슐이 구분선을 "뚫고" 나오는 느낌이 됨
- 더 나은 방법: 구분선을 시간 열 Stack 안에 `Positioned(right: 0)` 오른쪽 가장자리 세로선으로 넣고, 캡슐을 그 위에 렌더링 (Stack 내 순서: 구분선 먼저, 캡슐 나중)
  ```dart
  Stack(
    clipBehavior: Clip.none,
    children: [
      // ... 시간 레이블들 ...
      // 구분선 (먼저 paint)
      Positioned(
        top: 0, bottom: 0, right: -calendarDividerThickness,
        child: Container(width: calendarDividerThickness, color: context.separator),
      ),
      // 캡슐 (나중에 paint → 구분선 위에 렌더링)
      CurrentTimeCapsule(hourHeight: hourHeight),
    ],
  )
  ```
- 이 방식을 쓰면 Row의 `Container(width: 0.5)` 구분선은 제거 (Stack 내부에서 처리)
- **주의**: 17-2에서 수직 구분선을 헤더 이하로만 표시하는 수정과 함께 적용해야 함

**구현 순서 권장**: 17-2와 17-3을 묶어서 한 번에 수정.

---

## Phase 16 신규 발견 사항 (2026-03-20 세션)

### 16-1: 바운싱 스크롤 전체 날짜 열 동기화 재시도

Phase 15-1에서 `BouncingScrollPhysics` 복원 + bouncing 범위 sync 차단을 적용했으나, 이로 인해 **overscroll 시 드래그 중인 날짜 열만 늘어나고 나머지 2열은 정지**하는 현상이 남아 있음.

**원인 분석**:
- `_controllerForPage` 리스너: `offset < 0 || offset > maxExtent`이면 sync를 완전 차단
- `jumpTo()`는 bounds 밖 값 거부 → bouncing offset을 다른 컨트롤러에 전달 불가

**해결 방향**: `ScrollPosition.correctPixels(offset)` + `position.notifyListeners()` 활용
- `correctPixels`는 Flutter ScrollPosition 내부 메서드로 bounds 체크 없이 `_pixels` 직접 설정
- bouncing 중에도 이 방법으로 다른 컨트롤러에 overscroll offset 전파 가능
- `_currentVerticalOffset`은 bouncing 중 업데이트 생략 → 정상 범위 복귀 시 자동 재동기화
- 별도 `_syncAllScrollControllersBouncing()` 메서드로 분리
- 파일: `three_day_calendar.dart` `_controllerForPage` 리스너 + 신규 메서드 추가

**주의**: 시간 열(`_timeColumnScrollController`)은 `NeverScrollableScrollPhysics`이나, `correctPixels`는 physics 우회하므로 적용 가능

### 16-2: 네비바 chevron 아이콘 비율 수정

**현재**: `CustomPaint(size: const Size(12, 7))` + `strokeWidth: 1.5, strokeCap: round`
- V 형태: arm 각도 ≈ 49° (너무 좁게 벌어짐)
- `strokeCap.round`로 선 끝에 추가 픽셀 → 시각적으로 비율이 더 이상해 보임

**해결**: 너비 12 유지, 높이를 줄여 각도를 넓힘
- `Size(12, 6)` 시도 → 각 arm 45° (일반적으로 자연스러운 chevron 형태)
- 파일: `home_nav_bar.dart` `_ChevronIcon.build()` → `CustomPaint(size: const Size(12, 7))` 수정

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

## ThreeDayCalendar 구조 (현재, Phase 19 기준)

```
ConsumerStatefulWidget (_ThreeDayCalendarState)
├── _referenceDate = DateTime(2001, 1, 1)  ← 고정 기준일
├── _initialPage = today.difference(referenceDate).inDays  ← 오늘의 페이지 인덱스
├── _pageController (PageController, viewportFraction: 1/3, initialPage: _initialPage)
├── _timeColumnScrollController (ScrollController, NeverScrollableScrollPhysics)
├── _dayScrollControllers: Map<int, ScrollController> (페이지별)
├── _currentVerticalOffset: double (공유 수직 오프셋)
├── _isSyncing: bool (sync 재진입 방지)
├── _isPageAnimating: bool (animateToPage 중 onPageChanged 차단)
├── _scrollToCurrentTimePending: bool (animateToPage 완료 후 scrollToCurrentTime 예약)
├── _controllerForPage(page):
│   ├── isInitialized: bool (로컬 closure 변수)
│   ├── addListener: isInitialized == false이면 return (stale offset 덮어쓰기 방지)
│   └── postFrameCallback: isInitialized=true + ctrl.jumpTo(_currentVerticalOffset) 교정
├── _dateForPage(page) = _referenceDate.add(Duration(days: page))
│   ← page가 _initialPage이면 오늘, page+1이면 내일
└── build():
    GestureDetector (핀치 줌)
    └── Stack  ← Phase 19: Row → Stack 교체 (구분선 overlay용)
        ├── Row
        │   ├── SizedBox(width: 44)  ← 고정 시간 열
        │   │   └── Column
        │   │       ├── SizedBox(height: 28)  ← threeDayHeaderHeight 공백
        │   │       ├── Container(height: 0.5, separator)
        │   │       ├── SizedBox(height: 40) "종일" 레이블
        │   │       ├── Container(height: 0.5, separator)
        │   │       └── Expanded → SingleChildScrollView(NeverScrollable)
        │   │           └── SizedBox(hourHeight*24)
        │   │               └── Stack(clipBehavior: Clip.none)
        │   │                   ├── for hour 1~23: Positioned(top: hourHeight*hour, right: 2)
        │   │                   │   └── FractionalTranslation(0, -0.5) → Text("HH:00")
        │   │                   └── CurrentTimeCapsule(hourHeight)
        │   │                       ← Positioned(right: currentTimeCapsuleRightInset) = 0.25
        │   └── Expanded → PageView.builder(padEnds: false)
        │       └── itemBuilder → Stack
        │           ├── Column
        │           │   ├── SizedBox(height: 28) → _DayHeaderCell
        │           │   ├── Container(height: 0.5)
        │           │   ├── AllDayCell
        │           │   ├── Container(height: 0.5)
        │           │   └── Expanded → TimeGrid(scrollController, isToday)
        │           │       └── Stack(clipBehavior: Clip.none)  ← Clip.none 추가 (Phase 19)
        │           │           ├── 수평 구분선 (1~23시)
        │           │           └── CurrentTimeLine(hourHeight, isToday)
        │           │               ← Positioned(left: -currentTimeCapsuleRightInset) = -0.25
        │           └── Positioned(top: 28.5, bottom: 0, right: 0)  ← 날짜 열 right border
        │               └── Container(width: 0.5, separator)
        └── Positioned(left: 44, top: 28.5, bottom: 0)  ← 시간열↔날짜열 수직 구분선 overlay
            └── SizedBox(width: 0.5, child: ColoredBox(separator))
```

### ref.listen 목록 (selectedStartDate)
- `targetPage = next.difference(_referenceDate).inDays` ← _initialPage + delta 아님!
- `kind == animate` → `animateToPage.then()` 후 `_scrollToCurrentTimePending` 확인
- `kind != animate` → `jumpToPage`

### ref.listen 목록 (scrollToCurrentTimeTrigger)
- `_isPageAnimating == true` → `_scrollToCurrentTimePending = true` (예약)
- `_isPageAnimating == false` → `addPostFrameCallback(_scrollToCurrentTime)` (즉시)

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
- 지원 범위: **2001.01.01 ~ 2100.12.31** (Phase 17-4 + 18-4에서 완전 구현)
- `_referenceDate = DateTime(2001, 1, 1)` (고정)
- `_initialPage = today.difference(2001-01-01).inDays` ≈ 9210
- `_dateForPage(page) = _referenceDate.add(Duration(days: page))`
  - page 0 = 2001-01-01, page _initialPage = 오늘, page 36524 ≈ 2100-12-31
- **주의**: 구 공식 `page - _initialPage`는 틀린 공식. 혼용하지 말 것.

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
