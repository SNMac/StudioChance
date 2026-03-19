# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-19

## Phase 1: 상수 및 상태 관리 기반 ✅

### 1-1. UI 상수 추가
- [x] `ui_constants.dart`에 홈 화면 관련 상수 추가
  - `homeNavBarHeight`, `allDayRowHeight`, `defaultHourHeight`
  - `minHourHeight`, `maxHourHeight`
  - `calendarDividerThickness`, `currentTimeLineThickness`
  - `currentTimeCapsuleWidth`, `currentTimeCapsuleHeight`
  - `tabBarHeight`, `timeColumnWidth`
  - `monthlyCalendarHeight`, `monthlyCalendarDayRowHeight`, `monthlyCalendarWeekdayRowHeight`

### 1-2. HomeCalendarState (Freezed)
- [x] `lib/presentation/providers/home_calendar_controller.dart` 생성
- [x] `HomeCalendarState` freezed 클래스 정의
- [x] `HomeCalendarController` Riverpod Notifier 구현 (5개 메서드)
- [x] 코드 생성 실행 (`build_runner`)

### 1-3. HourHeight 영구 저장
- [x] `lib/presentation/providers/hour_height_preference_provider.dart` 생성
- [x] SharedPreferences read/write 로직 구현
- [x] HomeCalendarController `build()`에서 저장값 불러오기
- [x] `updateHourHeight` 호출 시 SharedPreferences 저장

---

## Phase 2: 하단 탭바 ✅

### 2-1. HomeTabBar 위젯
- [x] `lib/presentation/home/widgets/home_tab_bar.dart` 생성
- [x] 탭 3개 구현 (홈, 예약 통계, 마이페이지)
- [x] 선택/비선택 아이콘 및 색상 처리
- [x] 높이: 49 + SafeArea bottom
- [x] 로컬 상태로 선택 탭 관리 (StatefulWidget)

---

## Phase 3: 네비게이션 바 ✅

### 3-1. HomeNavBar 위젯
- [x] `lib/presentation/home/widgets/home_nav_bar.dart` 생성
- [x] 좌측: 연월 + chevron 버튼 (chevron up/down 전환)
- [x] 우측: calendar_circle 버튼 + CupertinoDatePicker
- [x] 우측: 오늘 날짜 원형 버튼

---

## Phase 4: 월간 캘린더 ✅

### 4-1. MonthlyCalendarHeader
- [x] `monthly_calendar_header.dart` 생성 (일~토 7열)

### 4-2. MonthlyCalendarGrid
- [x] `monthly_calendar_grid.dart` 생성
- [x] 5행 × 7열 고정, 날짜 계산, opacity 처리
- [x] 선택 상태 표시 (3일 범위)

### 4-3. MonthlyCalendar 조합
- [x] `monthly_calendar.dart` 생성 (Header + Grid)

---

## Phase 5: 3일 캘린더 헤더 ✅

### 5-1. ThreeDayHeader
- [x] `three_day_header.dart` 생성
- [x] 3열 요일/일자, 오늘 원형 배경, 토/일 색상
- [x] 하단 구분선

---

## Phase 6: 3일 캘린더 바디 ✅

### 6-1. AllDayRow
- [x] `all_day_row.dart` 생성

### 6-2. CurrentTimeIndicator
- [x] `current_time_indicator.dart` 생성 (Timer 1분, 캡슐+선)

### 6-3. TimeGrid
- [x] `time_grid.dart` 생성 (스크롤, 구분선, 핀치줌, 현재시간선)

### 6-4. ThreeDayCalendar 조합
- [x] `three_day_calendar.dart` 생성 (스와이프 날짜 이동)

---

## Phase 7: HomeScreen 최종 조합 ✅

- [x] `lib/presentation/home/screens/home_screen.dart` ConsumerWidget으로 구현
  - HomeNavBar + AnimatedContainer(MonthlyCalendar) + ThreeDayCalendar 조합
  - HomeTabBar (Scaffold bottomNavigationBar)
  - HomeCalendarController 연결

---

## 최종 검증

- [ ] 다크 모드 색상 정상 표시
- [ ] 오늘 날짜 자동 설정 확인
- [ ] 월간 캘린더 접힘/펼침 애니메이션 동작
- [ ] 3일 캘린더 스와이프 날짜 이동
- [ ] 현재 시간선 1분 업데이트 확인
- [ ] 확대/축소 후 앱 재시작 시 저장값 복원
- [ ] `dart analyze lib/` 에러 없음 ✅ (2026-03-19 확인)
