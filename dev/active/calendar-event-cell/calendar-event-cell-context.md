# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-03-27 (2차)

---

## 핵심 파일

### 수정 대상

| 파일 | 위치 | 수정 내용 |
|------|------|----------|
| `colors.dart` | `lib/presentation/colors.dart` | 색상 21개 추가 |
| `ui_constants.dart` | `lib/constants/ui_constants.dart` | `defaultHourHeight` 36→40, `minHourHeight` 18→40 |
| `all_day_row.dart` | `lib/presentation/home/widgets/three_day_calendar/` | `events` 파라미터, 셀 배치 |
| `time_grid.dart` | `lib/presentation/home/widgets/three_day_calendar/` | `events` 파라미터, 셀 배치 |
| `three_day_calendar.dart` | `lib/presentation/home/widgets/three_day_calendar/` | 목업 데이터 전달 |

### 신규 생성

| 파일 | 위치 | 내용 |
|------|------|------|
| `reservation_cell.dart` | `lib/presentation/home/widgets/three_day_calendar/` | ReservationCell 위젯 + 관련 타입 |

---

## 현재 코드 상태

### `all_day_row.dart` (현재)
```dart
class AllDayCell extends StatelessWidget {
  const AllDayCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: allDayRowHeight); // 빈 상태
  }
}
```

### `time_grid.dart` Stack children (현재)
```dart
Stack(
  children: [
    const SizedBox.expand(),
    // 수평 시간 구분선 (1~23시)
    for (int hour = 1; hour < 24; hour++)
      Positioned(top: hourHeight * hour, left: 0, right: 0,
        child: Divider(height: 0, thickness: calendarDividerThickness, ...)),
    // 현재 시간선
    CurrentTimeLine(hourHeight: hourHeight, isToday: isToday),
  ],
)
```

### `ui_constants.dart` 관련 상수
```dart
const double allDayRowHeight = 40.0;   // 종일 행 높이 (변경 없음)
const double defaultHourHeight = 36.0; // 기본 시간 높이 (변경 없음)
const double minHourHeight = 18.0;     // ← 40.0으로 변경
const double maxHourHeight = 72.0;     // 변경 없음
const double calendarDividerThickness = 0.5; // 변경 없음
```

### `three_day_calendar.dart` 이벤트 전달 지점
```dart
// Line ~444: AllDayCell 사용
const AllDayCell(), // → AllDayCell(events: _eventsForDate(date, allDay: true))

// Line ~451: TimeGrid 사용
Expanded(
  child: TimeGrid(
    scrollController: _controllerForPage(index),
    isToday: _isToday(date),
  ), // → events: _eventsForDate(date, allDay: false) 추가
),
```

---

## 외부 의존성

### flutter_svg (pubspec.yaml)
```yaml
flutter_svg: ^2.2.3
```
- 이미 추가됨 ✅
- `SvgPicture.asset()`으로 circle_slash.svg 렌더링
- 색상 적용: `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)`

### SVG 에셋
SVG 에셋 (3종 모두 확인됨):
- `assets/images/icons/checkmark_circle_fill.svg` ✅ (예약 확정)
- `assets/images/icons/circle_dashed.svg` ✅ (입금 대기, viewBox 10×10, fill="black" 확인됨)
- `assets/images/icons/circle_slash.svg` ✅ (예약 취소)

---

## 색상 구현 참고

### 기존 `context_colors.dart` 패턴
```dart
// CupertinoDynamicColor 방식 (Light/Dark 자동 적응)
Color get systemRed =>
    CupertinoDynamicColor.resolve(CupertinoColors.systemRed, this);
```

### 셀 색상 주의사항
- 셀 색상 21개는 **라이트 모드 전용 고정 색상**입니다 (디자인 스펙상 Light/Dark 구분 없음).
- `context_colors.dart` extension에 추가하지 않고, `colors.dart`에 `const Color` 상수로 정의합니다.
- `CupertinoDynamicColor` 불필요.

---

## 셀 위치 계산 (TimeGrid)

```dart
// startTime, endTime이 null이 아닌 경우만 TimeGrid에 배치
double _topOffset(ReservationDisplayData event, double hourHeight) {
  final start = event.startTime!;
  return hourHeight * (start.hour + start.minute / 60) + 0.5;
}

double _cellHeight(ReservationDisplayData event, double hourHeight) {
  final minutes = event.endTime!.difference(event.startTime!).inMinutes;
  return hourHeight * (minutes / 60) - 1.0; // 0.5 top + 0.5 bottom inset
}
```

---

## 아이콘 구현

모든 상태 아이콘을 SVG로 통일 (Light weight 문제 해결됨):
- `checkmark_circle_fill.svg` → 예약 확정 (Light weight SVG)
- `circle_dashed.svg` → 입금 대기 (점선 원, Light weight SVG)
- `circle_slash.svg` → 예약 취소

렌더링 방식:
```dart
SvgPicture.asset(
  path,
  width: 12,
  height: 12,
  colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
)
```

**주의:** `BlendMode.srcIn`은 SVG 내부 fill을 지정 색상으로 교체합니다. SVG의 최상위 path가 `fill="black"` (또는 임의의 단색)이어야 합니다. circle_dashed.svg 확인됨 ✅

---

## 관련 문서

- `dev/active/home-screen/home-screen-plan.md` - Phase 6 (AllDay), Phase 6-2 (TimeGrid)
- `dev/active/home-screen/home-screen-tasks.md` - 전체 진행 상황
