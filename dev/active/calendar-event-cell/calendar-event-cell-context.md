# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-03-27 (3차 — 구현 완료)

---

## 현재 구현 상태

**모든 Phase 구현 완료, 버그 수정 완료. flutter analyze 오류 없음.**

---

## 수정된 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/colors.dart` | 색상 21개 추가 (Background/Foreground/Label × 7) |
| `lib/constants/ui_constants.dart` | defaultHourHeight 36→40, minHourHeight 18→40 |
| `lib/presentation/providers/hour_height_preference_provider.dart` | loadHourHeight에 clamp 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart` | **신규** — 전체 셀 구현 |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` | events 파라미터 추가, 셀 배치 |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | events 파라미터 추가, 셀 배치 |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | import 추가, 목업 데이터, 호출부 연결 |

---

## 핵심 결정 및 설계

### 색상 구조 (확정)

```
좌측 4px 스트립 → colorTheme.foregroundColor (~Foreground, 진한 색)
우측 라벨 영역 배경 → colorTheme.backgroundColor (~Background, 연한 색)
텍스트/아이콘 → colorTheme.labelColor (~Label, 어두운 색)
```

> ⚠️ 초기 구현 시 스트립/배경 색상이 반전되어 있었음. 수정 완료.

### 아이콘 위치

```
Row: [SizedBox(8)] [Icon] [SizedBox(2.5)] [텍스트 Column]
       ↑                   ↑
  스트립(4px)+간격(4px)   아이콘↔텍스트 간격
```

- `SizedBox(width: 8)` = 스트립 4px + 라벨 영역 왼쪽에서 4px 간격
- 초기 구현은 `SizedBox(width: 4)`로 아이콘이 스트립에 붙어있는 느낌이었음 → 8로 수정

### 라벨 높이 (Figma 16px vs Flutter labelSmall 15px)

- `labelSmall`: fontSize=10, height=1.5 → 라인 높이 15px
- Figma 스펙 16px와 1px 차이 → 시각적으로 구분 불가, 높이 오버라이드 없이 `labelSmall` 그대로 사용

### 아이콘 (모두 SVG)

| 상태 | 파일 |
|------|------|
| confirmed | `assets/images/icons/checkmark_circle_fill.svg` |
| pendingPayment | `assets/images/icons/circle_dashed.svg` (viewBox 10×10) |
| cancelled | `assets/images/icons/circle_slash.svg` |

공통: `SvgPicture.asset(path, width:12, height:12, colorFilter: ColorFilter.mode(lblColor, BlendMode.srcIn))`

### minHourHeight 변경 주의사항

- `defaultHourHeight` 36→40, `minHourHeight` 18→40 함께 변경
- `HomeCalendarController.build()`에서 초기값이 clamp 없이 state에 주입 → 두 값 동기화 필수
- `loadHourHeight`에 `.clamp()` 추가 → 이전 기기에 36이 저장된 경우 40으로 보정

### ReservationDisplayData (임시 뷰 모델)

```dart
// TODO: 예약(Reservation) 도메인 엔티티 정의 후 교체 예정
class ReservationDisplayData {
  final String reserverName;
  final int headcount;
  final String phoneNumber;
  final ReservationStatus status;
  final ReservationCellColorTheme colorTheme;
  final bool isAllDay;
  final DateTime? date;       // 종일 이벤트용
  final DateTime? startTime;  // 시간대 이벤트용
  final DateTime? endTime;    // 시간대 이벤트용
}
```

---

## 목업 데이터 구성 (ThreeDayCalendar._mockEvents)

오늘(`today`) 기준 상대 날짜, `_buildMockEvents()` static 메서드로 앱 시작 시 1회 생성:

| 날짜 | 시간 | 상태 | 색상 |
|------|------|------|------|
| 오늘 | 종일 | confirmed | green |
| 오늘 | 07:00~08:30 | confirmed | green |
| 오늘 | 10:00~13:00 | cancelled | green |
| 내일 | 10:00~14:00 | pendingPayment | yellow |
| 내일 | 15:00~16:00 | confirmed | blue |
| 모레 | 종일 | pendingPayment | orange |
| 모레 | 13:00~15:00 | cancelled | purple |

---

## 셀 배치 오프셋 (확정)

| 영역 | left | right | top | bottom |
|------|------|-------|-----|--------|
| 종일(AllDay) | 1 | 8 | 1 | 4 |
| 시간대(TimeGrid) | 1 | 8 | +0.5 | −0.5 |

TimeGrid 위치 계산:
```dart
top    = hourHeight * (start.hour + start.minute / 60) + 0.5
height = hourHeight * duration_minutes / 60 - 1.0  (clamp 1.0 이상)
```

---

## 다음 작업 (추후)

1. **다중 이벤트 겹침 레이아웃** — 동일 날짜/시간에 예약이 겹칠 때 분할 표시
2. **실제 데이터 연결** — Reservation 도메인 엔티티 + Riverpod provider
3. **셀 탭** → 예약 상세 화면 이동
4. **빌드 러너 불필요** — 이번 구현에 코드 생성 없음 (freezed/riverpod 미사용)

---

## 외부 의존성

```yaml
flutter_svg: ^2.2.3  # pubspec.yaml에 이미 포함
```

SVG 에셋 (pubspec.yaml assets에 등록 필요 여부는 `assets/images/icons/` 폴더 전체가 이미 등록되어 있는지 확인 권장):
- `assets/images/icons/checkmark_circle_fill.svg`
- `assets/images/icons/circle_dashed.svg`
- `assets/images/icons/circle_slash.svg`
