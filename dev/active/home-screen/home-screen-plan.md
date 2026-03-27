# 홈 화면 구현 계획

Last Updated: 2026-03-19

## 개요

공간대여업 예약 관리 앱의 핵심 화면인 홈 화면을 구현합니다.
3일 캘린더 기반의 일정 뷰, 월간 캘린더 (접힘/펼침), 네비게이션 바, 하단 탭바로 구성됩니다.

---

## 현재 상태

- `HomeScreen` - `Placeholder()` 상태 (미구현)
- `SCRoute.home` 라우트는 정의됨
- `secondarySystemFill` 색상 확장 추가 완료

---

## 구현할 화면 구성

```
HomeScreen (Scaffold)
├── Column (body)
│   ├── HomeNavBar                  높이 44
│   ├── AnimatedContainer           월간 캘린더 (접힘 ↔ 펼침)
│   │   └── MonthlyCalendar
│   └── Expanded
│       └── ThreeDayCalendar
│           ├── ThreeDayHeader      요일/일자 고정 헤더
│           ├── AllDayRow           종일 이벤트 고정 (높이 40)
│           └── Expanded
│               └── ScrollView      시간 그리드 (스크롤)
│                   ├── TimeColumn  시간 레이블 (좌측)
│                   ├── DayColumns  3열 이벤트 그리드
│                   └── CurrentTimeIndicator  현재 시간선
└── HomeTabBar                      하단 탭바 (UI only)
```

---

## 디자인 스펙

### 색상 참조
| 항목 | 색상 |
|------|------|
| 기본 텍스트 | `context.label` |
| 보조 텍스트 | `context.secondaryLabel` |
| 배경 | `context.systemBackground` |
| 구분선 | `context.separator` |
| 선택 배경(주) | `context.label` (숫자: `systemBackground`) |
| 선택 배경(나머지) | `context.secondarySystemFill` |
| 일요일 | `context.systemRed` |
| 토요일 | `context.systemBlue` |
| 현재 시간선 | `context.systemRed` |
| 탭바 기본 | `Color(0xFF999999)` |
| 탭바 선택 | `context.systemBlue` |

### 폰트 참조
| 항목 | 스타일 |
|------|--------|
| 연월 버튼 | `bodyLarge` (16px, w500) |
| 3일 헤더 요일/일자 | `bodyMedium` (14px, w500) |
| 오늘 날짜 버튼 숫자 | `bodyLarge` (16px, normal) |
| 월간 캘린더 요일 | `labelMedium` (12px, w400) |
| 월간 캘린더 날짜 | `labelLarge` 크기만 16px |
| 시간 레이블 | `labelSmall` (10px, w400) |
| 현재 시간 캡슐 | `bodySmall` 크기만 10px, white |

### 치수
| 항목 | 크기 |
|------|------|
| 네비게이션 바 높이 | 44 |
| 월간 캘린더 날짜 셀 | 40 × 40, radius 8 |
| 종일 이벤트 영역 높이 | 40 |
| 시간 간격 높이 (기본) | 36 |
| 시간 간격 최소/최대 | 18 / 72 (0.5x ~ 2.0x) |
| 구분선 두께 | 0.5 |
| 현재 시간선 두께 | 1.0 |
| 현재 시간 캡슐 크기 | 32 × 13 |
| 탭바 아이콘/버튼 터치 영역 | 44 × 44 |
| 아이콘/동그라미 실제 크기 | 20 × 20 |
| 탭바 높이 | 49 (+ SafeArea) |

---

## 구현 단계

### Phase 1: 상수 및 상태 관리 기반

**목표**: 홈 화면 전체의 상태를 관리할 Provider와 UI 상수를 정의합니다.

#### 1-1. UI 상수 추가 (`lib/constants/ui_constants.dart`)
- 네비게이션 바 높이: `homeNavBarHeight = 44.0`
- 종일 이벤트 높이: `allDayRowHeight = 40.0`
- 시간 간격 기본값: `defaultHourHeight = 36.0`
- 시간 간격 최솟값: `minHourHeight = 18.0`
- 시간 간격 최댓값: `maxHourHeight = 72.0`
- 구분선 두께: `calendarDividerThickness = 0.5`
- 현재 시간선 두께: `currentTimeLineThickness = 1.0`
- 현재 시간 캡슐 너비: `currentTimeCapsuleWidth = 32.0`
- 현재 시간 캡슐 높이: `currentTimeCapsuleHeight = 13.0`
- 탭바 높이: `tabBarHeight = 49.0`

#### 1-2. HomeCalendarController 구현
파일: `lib/presentation/providers/home_calendar_controller.dart`

```
상태: HomeCalendarState (freezed)
  - selectedStartDate: DateTime    // 3일 캘린더 첫 번째 날짜
  - isMonthlyCalendarVisible: bool // 월간 캘린더 표시 여부
  - hourHeight: double             // 시간 간격 높이 (확대/축소)
  - displayedMonth: DateTime       // 네비바에 표시되는 연월
```

메서드:
- `selectDate(DateTime date)` - 날짜 선택 (selectedStartDate 변경)
- `toggleMonthlyCalendar()` - 월간 캘린더 토글
- `updateHourHeight(double height)` - 확대/축소 (clamp 적용)
- `goToToday()` - 오늘 날짜로 이동
- `navigateDays(int days)` - n일 이동 (스와이프 완료 시)

#### 1-3. HourHeightPreference 저장
파일: `lib/presentation/providers/hour_height_preference_provider.dart`

`SharedPreferences`를 이용하여 hourHeight를 영구 저장.
앱 시작 시 저장된 값을 불러와 HomeCalendarController 초기값으로 사용.

키: `'hour_height_preference'`

---

### Phase 2: 하단 탭바

**목표**: UI only 탭바 구현 (탭 전환은 추후 GoRouter 연동)

파일: `lib/presentation/home/widgets/home_tab_bar.dart`

#### 탭 구성
| 탭 | 기본 아이콘 | 선택 아이콘 | 레이블 |
|---|---|---|---|
| 홈 | `CupertinoIcons.house` | `CupertinoIcons.house_fill` | 홈 |
| 예약 통계 | `CupertinoIcons.chart_bar` | `CupertinoIcons.chart_bar_fill` | 예약 통계 |
| 마이페이지 | `CupertinoIcons.person` | `CupertinoIcons.person_fill` | 마이페이지 |

> **참고**: `chart.line.uptrend.xyaxis`는 Flutter CupertinoIcons에 없으므로 `chart_bar` / `chart_bar_fill` 사용.

- 높이: 49 + `MediaQuery.of(context).padding.bottom`
- 기본 색상: `Color(0xFF999999)`
- 선택 색상: `context.systemBlue`
- 현재 선택 탭 상태 관리: `_HomeTabBarState` (StatefulWidget, 로컬 상태)

---

### Phase 3: 네비게이션 바 (HomeNavBar)

파일: `lib/presentation/home/widgets/home_nav_bar.dart`

#### 좌측: 연월 버튼
- `Text('2026년 3월') + Icon(CupertinoIcons.chevron_down)` 수평 Row
- 월간 캘린더 표시 시 `chevron_up`으로 변경
- 폰트: `bodyLarge`
- 탭 시 `toggleMonthlyCalendar()` 호출

#### 우측: calendar.circle 버튼 + 오늘 날짜 버튼
- 터치 영역: 44 × 44 각각
- 아이콘 실제 크기: 20 × 20

**calendar.circle 버튼**
- `CupertinoIcons.calendar_circle` (또는 유사 아이콘)
- 탭 시 `CupertinoDatePicker` (mode: date) 표시 → 선택 완료 시 `selectDate()` 호출
- Picker는 `showCupertinoModalPopup`으로 표시

**오늘 날짜 버튼**
- 숫자만 표시 (예: `19`)
- 원형 배경: `context.label`, 숫자: `context.systemBackground`
- 크기 20 × 20 (코너 radius 10)
- 폰트: `bodyLarge` (FontWeight.normal)
- 탭 시 `goToToday()` 호출

---

### Phase 4: 월간 캘린더

파일: `lib/presentation/home/widgets/monthly_calendar/monthly_calendar.dart`

#### 4-1. MonthlyCalendarHeader (요일 표시)
- 일월화수목금토 (고정 7열)
- 폰트: `labelMedium`
- 일: `context.systemRed`, 토: `context.systemBlue`, 나머지: `context.secondaryLabel`

#### 4-2. MonthlyCalendarGrid (날짜 그리드)
- 항상 5행 × 7열 표시
- 폰트 크기: 16 (labelLarge 스타일에서 크기만 16)
- 날짜 색상:
  - 일요일: `context.systemRed`
  - 토요일: `context.systemBlue`
  - 평일: `context.label`
  - 이전/다음 달: 불투명도 0.3
- 선택 상태 (3일 캘린더와 연동):
  - 첫 번째 날짜: 배경 `context.label`, 숫자 `context.systemBackground`
  - 나머지 2일: 배경 `context.secondarySystemFill`, 숫자 원래 색상 그대로
  - 선택 셀 크기: 40 × 40, radius 8
  - 탭 시 해당 날짜부터 3일 캘린더 표시 시작

#### 4-3. 접힘/펼침 애니메이션
- `AnimatedContainer`로 `height` 0 ↔ 월간 캘린더 전체 높이 전환
- 빌드 높이 계산: 요일 헤더 + 5행 × 셀 높이
- 월 변경: 연월 버튼 영역에서 좌우 스와이프 또는 월간 캘린더 내 좌우 스와이프 (추후 구현, 우선 고정)

---

### Phase 5: 3일 캘린더 헤더 (ThreeDayHeader)

파일: `lib/presentation/home/widgets/three_day_calendar/three_day_header.dart`

#### 열 구성
- 좌측: 시간 컬럼 너비 (글자 너비만큼, `labelSmall` 기준으로 대략 `"23:00"` 너비)
- 우측: 3열 (각 동일 너비, `Expanded`)

#### 날짜 셀 표시
- 요일 (위): `bodyMedium`, 기본 `secondaryLabel`
- 일자 (아래): `bodyMedium`, 기본 `secondaryLabel`
  - 토: `systemBlue`, 일: `systemRed`
  - 오늘: 요일 `label`, 일자는 원형 배경(`label`) + 숫자(`systemBackground`), 크기 20×20
- 하단 구분선: `separator`, 두께 0.5

---

### Phase 6: 3일 캘린더 바디

파일: `lib/presentation/home/widgets/three_day_calendar/`

#### 6-1. AllDayRow (종일 이벤트 행)
- 높이 40, 스크롤과 무관한 고정 영역
- 좌측 "종일" 레이블 (labelSmall, secondaryLabel)
- 우측 3열 (이벤트 없을 때 빈 상태)
- 하단 구분선

#### 6-2. TimeGrid (스크롤 가능 시간 그리드)
파일: `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

**구성**:
- `SingleChildScrollView` (vertical, controller로 초기 스크롤 위치 설정)
- `Stack` 내부:
  - 시간 구분선 (0~24시, 총 25개 구분선)
  - 시간 레이블 (좌측, labelSmall)
  - 3열 이벤트 영역 (현재 빈 상태)
  - CurrentTimeIndicator (현재 시간선)

**초기 스크롤**: 현재 시간이 화면 중앙에 위치하도록 계산
```
scrollOffset = currentHourOffset - (viewportHeight / 2)
```
- 최솟값: 0, 최댓값: totalHeight - viewportHeight

**확대/축소**:
- `GestureDetector.onScaleUpdate` 또는 `InteractiveViewer` (vertical 방향 핀치)
- hourHeight 변경 시 스크롤 위치도 비율에 맞게 재조정
- 확대/축소 종료 시 `SharedPreferences`에 저장

#### 6-3. CurrentTimeIndicator
파일: `lib/presentation/home/widgets/three_day_calendar/current_time_indicator.dart`

- `Timer.periodic(Duration(minutes: 1))` 로 1분마다 위치 업데이트
- 위치: `top = hourHeight * (currentHour + currentMinute / 60)`
- 좌측: 캡슐 (32×13, systemRed, 텍스트 "HH:MM", white, 10px)
- 우측: 수평 선 (시스템 빨강, 두께 1.0)

#### 6-4. ThreeDaySwipeController (스와이프 날짜 이동)
- `GestureDetector.onHorizontalDragEnd`
- velocity 또는 drag distance 기반으로 이동할 일수 결정
- 스냅: 스와이프 종료 시 날짜 경계(00:00)에 맞게 정렬
- 좌 스와이프 → 미래, 우 스와이프 → 과거

---

### Phase 7: HomeScreen 조합

파일: `lib/presentation/home/home_screen.dart`

- `ConsumerStatefulWidget` (ScrollController 필요)
- 전체 레이아웃 조합
- 월간 캘린더 AnimatedContainer 연결
- HomeCalendarController 연결

---

## 파일 구조

```
lib/
├── constants/
│   └── ui_constants.dart               # 상수 추가
├── presentation/
│   ├── providers/
│   │   ├── home_calendar_controller.dart
│   │   └── hour_height_preference_provider.dart
│   └── home/
│       ├── home_screen.dart
│       └── widgets/
│           ├── home_nav_bar.dart
│           ├── home_tab_bar.dart
│           ├── monthly_calendar/
│           │   ├── monthly_calendar.dart
│           │   ├── monthly_calendar_header.dart
│           │   └── monthly_calendar_grid.dart
│           └── three_day_calendar/
│               ├── three_day_calendar.dart
│               ├── three_day_header.dart
│               ├── all_day_row.dart
│               ├── time_grid.dart
│               └── current_time_indicator.dart
```

---

## 위험 요소 및 대응

| 위험 | 대응 |
|------|------|
| 확대/축소 시 스크롤 위치 불일치 | hourHeight 변경 전 비율 계산하여 offset 재조정 |
| 현재 시간선 realtime 업데이트로 인한 rebuild 범위 | CurrentTimeIndicator를 독립 위젯으로 분리, Timer는 해당 위젯 내부에서만 관리 |
| 월간 캘린더 5행 고정 시 6주짜리 달 처리 | 항상 5행만 표시하고 overflow 발생 날짜는 불투명도로 표현 |
| CupertinoIcons에 `chart.line.uptrend.xyaxis` 없음 | `chart_bar_alt_fill` 사용 또는 커스텀 SVG |
| 핀치 줌과 수직 스크롤 제스처 충돌 | `RawGestureDetector` + `ScaleGestureRecognizer`로 명시적 제스처 분리 |

---

## 미구현 (추후 작업)

- 이벤트 표시 UI (월간/3일 캘린더 모두)
- FAB (+ 버튼)
- 월 변경 스와이프
- 탭바 GoRouter 연동
- 예약 통계 화면, 마이페이지 화면
