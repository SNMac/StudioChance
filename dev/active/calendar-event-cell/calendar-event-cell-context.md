# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-03-27 (10차 — 이벤트 겹침 레이아웃 구현)

---

## 현재 구현 상태

**Phase 1~7 구현 완료, 버그 수정 완료. flutter analyze 오류 없음.**

> 4차 수정: 아이콘 크기 12→10, 상단 간격 2→4, 우측 최소 4px 여백, FittedBox 자동 축소, 아이콘-첫 텍스트 세로 중앙 정렬 적용.
> 7차 수정: minHourHeight 40→36 (사용자 정정 — 최소 시간 간격 높이 36px). 6차에서 추가한 Padding bottom:4 롤백 — FittedBox 높이를 제한해 텍스트가 축소되는 부작용 확인, 피그마 스펙과 맞지 않음.
> 10차 수정: 이벤트 겹침 레이아웃 구현 (2개 기준). _computePositions() + ReservationCell.clipContent.

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

### 아이콘 위치 및 레이아웃

```
Row:
  [SizedBox(8)]  ← 스트립(4px)+간격(4px)
  Expanded(
    Padding(top:1.5, right:4)
    FittedBox(scaleDown, topLeft)
      Row(crossAxis: start)
        SizedBox(height:15, Center(Icon 10×10))  ← 셀 상단~아이콘 상단 = 1.5 + 2.5 = 4px
        SizedBox(width:2.5)
        Column: [이름·인원] [전화번호]
  )
```

- `SizedBox(width: 8)` = 스트립 4px + 라벨 영역 왼쪽에서 4px 간격
- 초기 구현은 `SizedBox(width: 4)`로 아이콘이 스트립에 붙어있는 느낌이었음 → 8로 수정
- `FittedBox(fit: BoxFit.scaleDown)` — 콘텐츠가 너무 좁을 때 아이콘+텍스트 전체를 비율 유지하며 축소 (넓이·높이 모두 적용)
- `SizedBox(height: 15.0, child: Center(child: icon))` — labelSmall 라인 높이(10×1.5=15px)와 아이콘 중앙 정렬
- 아이콘 크기: 10×10 (초기 12×12에서 수정)
- 상단 간격: `top: 1.5` — 아이콘(10px)이 SizedBox(15px) 안에서 중앙정렬되므로 위 여백 2.5px 추가 → 셀 상단~아이콘 상단 = 1.5 + 2.5 = **4px**
- 우측 여백: `Padding(right: 4)`가 FittedBox 전체를 감쌈 → FittedBox 가용폭 = `셀너비 - 8(좌) - 4(우)`. 첫째·둘째 텍스트 라인 모두 이 범위 내에서 렌더링되므로 두 라벨 모두 우측 4px 여백 보장
- `overflow: TextOverflow.ellipsis` 제거 — FittedBox가 축소하므로 ellipsis 불필요
- `labelSmall`의 `height: 1.5` 유지 — 줄 간격 변경 시 시각적으로 딱 붙어보이므로 기본값 유지

> ⚠️ bottom padding 관련 주의: Padding(bottom:N)을 추가하면 FittedBox의 가용 높이가 줄어 텍스트 축소 발생.
> 종일 셀 기준: 셀 높이 35px, top:4 후 FittedBox 가용 31px, 콘텐츠 30px → bottom ≤ 1px에서만 축소 없음.
> 피그마 스펙은 외부 Positioned(bottom:4)만 사용하며, 내부 Padding에 bottom 값 없음 — 이를 유지할 것.

### 라벨 높이 (Figma 16px vs Flutter labelSmall 15px)

- `labelSmall`: fontSize=10, height=1.5 → 라인 높이 15px
- Figma 스펙 16px와 1px 차이 → 시각적으로 구분 불가, 높이 오버라이드 없이 `labelSmall` 그대로 사용

### 아이콘 (모두 SVG)

| 상태 | 파일 |
|------|------|
| confirmed | `assets/images/icons/checkmark_circle_fill.svg` |
| pendingPayment | `assets/images/icons/circle_dashed.svg` (viewBox 10×10) |
| cancelled | `assets/images/icons/circle_slash.svg` |

공통: `SvgPicture.asset(path, width:10, height:10, colorFilter: ColorFilter.mode(lblColor, BlendMode.srcIn))`

### minHourHeight 변경 주의사항

- `defaultHourHeight` 36→40, `minHourHeight` 18→36 변경 (최소 시간 간격 높이 36px 기준 — 1시간 셀 최소 높이 = 36-1 = 35px)
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
| 시간대(TimeGrid) | 1 | 8 | +0.5 | −1.5 |

TimeGrid 위치 계산:
```dart
top    = hourHeight * (start.hour + start.minute / 60) + 0.5
height = hourHeight * duration_minutes / 60 - 2.0  (clamp 1.0 이상)
// 위 구분선 간격: 0.5px, 아래 구분선 간격: 1.5px
```

---

## 이벤트 겹침 레이아웃 설계 (Phase 7)

### z 순서 규칙

- 시작이 빠를수록 낮은 z (Stack에서 뒤에 위치)
- 같은 시작 시간이면 짧은 것이 낮은 z (긴 것이 위에 쌓임)
- 같은 시작+종료이면 목록 순서 유지 (안정 정렬)

### 열 배정 알고리즘

```dart
// 각 열의 마지막 이벤트 종료 시간을 추적
// 새 이벤트 시작 ≥ 열 종료 시간 → 해당 열 재사용 (겹치지 않음)
// 모든 열과 겹치면 새 열 추가
```

### 위치 계산

| 열 | left | right | clipContent |
|----|------|-------|-------------|
| 0 (뒤) | 1 | 8 | false (FittedBox) |
| 1+ (앞) | 52 | 8 | true (ClipRRect 잘림) |

`_overlapTopLeft = 52.0` 근거:
- 뒤 셀 내용 시작: 1(left) + 4(strip) + 4(gap) + 10(icon) + 2.5(gap) = 21.5px
- 3자(한글 10px 기준) ≈ 30px
- 21.5 + 30 ≈ 52px → 뒤 셀 이름 3자 노출
- 앞 셀 너비(115px 열 기준): 115 - 52 - 8 = 55px → 아이콘+3자 가능

### clipContent=true 레이아웃

```
Row:
  SizedBox(width:8) ← 스트립+간격
  Expanded(
    Padding(top:1.5)  ← right:0 (잘림으로 여백 불필요)
    Row(crossAxis: start)
      SizedBox(height:15, Center(Icon 10×10))
      SizedBox(width:2.5)
      Expanded(  ← 너비 채워서 자연스럽게 잘림
        Column: [이름·인원(clip)] [전화번호(clip)]
  )
```

### 3개 이상 겹침 (미구현, 추후 결정)

현재: 열 1과 동일 위치(left=52)로 처리됨 (겹쳐서 표시됨)

추천: **균등 분할(N등분, 노션 캘린더 방식)**
- 115px 열 기준: 2개=각53px, 3개=각35px
- 계단식 대안: 3번째 열 ~17px → 너무 좁아 실용 불가

## 다음 작업 (추후)

1. **3개 이상 겹침 레이아웃** — 균등 분할 방식 확정 후 구현
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
