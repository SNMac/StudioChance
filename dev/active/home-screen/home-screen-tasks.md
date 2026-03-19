# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-19

## Phase 1: 상수 및 상태 관리 기반

### 1-1. UI 상수 추가
- [ ] `ui_constants.dart`에 홈 화면 관련 상수 추가
  - `homeNavBarHeight`, `allDayRowHeight`, `defaultHourHeight`
  - `minHourHeight`, `maxHourHeight`
  - `calendarDividerThickness`, `currentTimeLineThickness`
  - `currentTimeCapsuleWidth`, `currentTimeCapsuleHeight`
  - `tabBarHeight`

### 1-2. HomeCalendarState (Freezed)
- [ ] `lib/presentation/providers/home_calendar_controller.dart` 생성
- [ ] `HomeCalendarState` freezed 클래스 정의
  - `selectedStartDate`, `isMonthlyCalendarVisible`, `hourHeight`, `displayedMonth`
- [ ] `HomeCalendarController` Riverpod Notifier 구현
  - `selectDate(DateTime)`, `toggleMonthlyCalendar()`
  - `updateHourHeight(double)` (clamp 적용)
  - `goToToday()`, `navigateDays(int)`
- [ ] 코드 생성 실행 (`build_runner`)

### 1-3. HourHeight 영구 저장
- [ ] `lib/presentation/providers/hour_height_preference_provider.dart` 생성
- [ ] SharedPreferences read/write 로직 구현
- [ ] HomeCalendarController `build()`에서 저장값 불러오기
- [ ] `updateHourHeight` 호출 시 SharedPreferences 저장

---

## Phase 2: 하단 탭바

### 2-1. HomeTabBar 위젯
- [ ] `lib/presentation/home/widgets/home_tab_bar.dart` 생성
- [ ] 탭 3개 구현 (홈, 예약 통계, 마이페이지)
- [ ] 선택/비선택 아이콘 및 색상 처리
- [ ] 높이: 49 + SafeArea bottom
- [ ] 로컬 상태로 선택 탭 관리 (StatefulWidget)

---

## Phase 3: 네비게이션 바

### 3-1. HomeNavBar 위젯
- [ ] `lib/presentation/home/widgets/home_nav_bar.dart` 생성
- [ ] 좌측: 연월 + chevron 버튼
  - 월간 캘린더 표시 여부에 따라 chevron up/down 전환
  - `bodyLarge` 폰트
- [ ] 우측: calendar.circle 버튼 (44×44 터치 영역, 아이콘 20×20)
  - `showCupertinoModalPopup`으로 날짜 picker
- [ ] 우측: 오늘 날짜 버튼 (44×44 터치, 원형 20×20)
  - 배경 `label`, 숫자 `systemBackground`
  - `bodyMedium` 폰트

---

## Phase 4: 월간 캘린더

### 4-1. MonthlyCalendarHeader
- [ ] `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_header.dart` 생성
- [ ] 일월화수목금토 7열 표시
- [ ] `labelMedium`, 일=systemRed, 토=systemBlue, 나머지=secondaryLabel

### 4-2. MonthlyCalendarGrid
- [ ] `lib/presentation/home/widgets/monthly_calendar/monthly_calendar_grid.dart` 생성
- [ ] 이전/해당/다음 달 날짜 계산 로직
- [ ] 5행 × 7열 고정 표시
- [ ] 날짜 색상: 일=systemRed, 토=systemBlue, 이전/다음달=opacity 0.3
- [ ] 선택 상태 표시: 첫째날(label bg + systemBackground text), 나머지 2일(secondarySystemFill bg)
- [ ] 날짜 탭 → `selectDate()` 호출

### 4-3. MonthlyCalendar 조합
- [ ] `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart` 생성
- [ ] Header + Grid 조합
- [ ] `AnimatedContainer` 접힘/펼침 연결 (HomeScreen에서 처리)

---

## Phase 5: 3일 캘린더 헤더

### 5-1. ThreeDayHeader
- [ ] `lib/presentation/home/widgets/three_day_calendar/three_day_header.dart` 생성
- [ ] 좌측 시간 컬럼 너비 공간 확보
- [ ] 3열: 요일 + 일자 표시
- [ ] 오늘: 요일 `label`, 일자 원형(`label` bg, `systemBackground` text)
- [ ] 비오늘: `secondaryLabel`, 토=systemBlue, 일=systemRed
- [ ] 하단 구분선 (separator, 0.5)

---

## Phase 6: 3일 캘린더 바디

### 6-1. AllDayRow
- [ ] `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` 생성
- [ ] 높이 40, 좌측 "종일" 레이블 (labelSmall, secondaryLabel)
- [ ] 3열 빈 영역 (이벤트 추후 추가)
- [ ] 하단 구분선

### 6-2. CurrentTimeIndicator
- [ ] `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart` 생성
- [ ] `Timer.periodic` 1분 업데이트
- [ ] 캡슐 UI (32×13, systemRed, "HH:MM", white, 10px)
- [ ] 수평선 (systemRed, 두께 1.0)
- [ ] hourHeight 변경 시 위치 재계산

### 6-3. TimeGrid
- [ ] `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` 생성
- [ ] 전체 높이: `hourHeight * 24`
- [ ] 시간 구분선 25개 (0~24시)
- [ ] 시간 레이블 (labelSmall, secondaryLabel)
- [ ] 초기 스크롤: 현재 시간 중앙 계산
- [ ] 3열 이벤트 영역 (빈 상태)
- [ ] CurrentTimeIndicator Stack 배치
- [ ] 핀치 줌 → `updateHourHeight()`, 스크롤 offset 비율 재조정

### 6-4. ThreeDayCalendar 조합
- [ ] `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` 생성
- [ ] Header + AllDayRow + TimeGrid 조합
- [ ] `GestureDetector` 수평 스와이프 → `navigateDays()` 호출
- [ ] 스와이프 시 날짜 경계에 스냅

---

## Phase 7: HomeScreen 최종 조합

- [ ] `lib/presentation/home/home_screen.dart` 업데이트
  - `ConsumerStatefulWidget`으로 변경
  - HomeNavBar + AnimatedContainer(MonthlyCalendar) + ThreeDayCalendar 조합
  - HomeTabBar 추가 (Scaffold bottomNavigationBar 또는 Column 최하단)
  - HomeCalendarController 연결

---

## 최종 검증

- [ ] 다크 모드 색상 정상 표시
- [ ] 오늘 날짜 자동 설정 확인
- [ ] 월간 캘린더 접힘/펼침 애니메이션 동작
- [ ] 3일 캘린더 스와이프 날짜 이동
- [ ] 현재 시간선 1분 업데이트 확인
- [ ] 확대/축소 후 앱 재시작 시 저장값 복원
- [ ] 코드 생성 파일 충돌 없음 (`build_runner`)
