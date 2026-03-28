# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-03-28 (Phase 8 완료 — Phase 9는 context reset 이후 진행)

---

## 현재 구현 상태

**Phase 1~8 구현 완료. flutter analyze 오류 없음.**
**Phase 9(셀 탭 인터랙션)는 context reset 이후 시작 예정.**

> Phase 7: 2개 이벤트 겹침 — 고정 `_overlapTopLeft=52.0` 방식 (Phase 8로 교체됨)
> Phase 8: 스택 레이아웃 + delta 기반 stagger + 오버플로우 셀 + 자정 넘김 + 바운스 연결 — **완료**
> Phase 9: 셀 탭 인터랙션 (팝업 애니메이션 + 모달) — **설계 확정, 미구현**
>
> 미결 디자인 결정: OverflowCell 배경 색상 (현재 `tertiarySystemFill` 임시)

---

## 수정된 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/colors.dart` | 색상 21개 추가 (Background/Foreground/Label × 7) |
| `lib/constants/ui_constants.dart` | defaultHourHeight 36→40, minHourHeight 18→36 |
| `lib/presentation/providers/hour_height_preference_provider.dart` | loadHourHeight에 clamp 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart` | **신규** — 전체 셀 구현, clipContent, isContinuation, continuesNextDay, 코너 반경 |
| `lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart` | **신규** — N개 오버플로우 셀 (멀티컬러 스트립 + "N개" 텍스트) |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` | events 파라미터 추가, 셀 배치 |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | 스택 레이아웃 알고리즘, delta stagger, 자정 넘김 배치, 바운스 연장 |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | 목업 데이터(전체 시나리오), _eventsForDate 자정 분할 |

---

## 핵심 결정 및 설계

### 색상 구조 (확정)

```
좌측 4px 스트립 → colorTheme.foregroundColor (~Foreground, 진한 색)
우측 라벨 영역 배경 → colorTheme.backgroundColor (~Background, 연한 색)
텍스트/아이콘 → colorTheme.labelColor (~Label, 어두운 색)
```

### 아이콘 위치 및 레이아웃 (일반 셀 / back 셀, clipContent=false)

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

### clipContent=true 레이아웃 (front/middle 셀, 스택 상위 셀)

```
Row:
  SizedBox(width:8) ← 스트립+간격
  Expanded(
    Padding(top:1.5)  ← right:0
    Row(crossAxis: start)
      SizedBox(height:15, Center(Icon 10×10))
      SizedBox(width:2.5)
      Expanded(
        Column: [이름·인원(TextOverflow.clip)] [전화번호(clip)]
  )
```

### 아이콘 (모두 SVG)

| 상태 | 파일 |
|------|------|
| confirmed | `assets/images/icons/checkmark_circle_fill.svg` |
| pendingPayment | `assets/images/icons/circle_dashed.svg` |
| cancelled | `assets/images/icons/circle_slash.svg` |

### minHourHeight 변경 주의사항

- `defaultHourHeight` = 40, `minHourHeight` = 36 (1시간 셀 최소 높이 = 36-1 = 35px)
- `loadHourHeight`에 `.clamp()` 추가로 이전 저장값 보정

---

## 목업 데이터 구성 (ThreeDayCalendar._mockEvents)

| 날짜 | 시간 | 상태 | 색상 | 시나리오 |
|------|------|------|------|---------|
| 오늘 | 종일 | confirmed | green | 단독 |
| 오늘 | 07:00~08:30 | confirmed | green | 단독 |
| 오늘 | 10:00 × 4개 | mixed | red/blue/green/yellow | N=4 오버플로우 |
| 오늘 | 16:00~17:00 | cancelled | purple | 단독 |
| 오늘 | 22:00~24:00 (+내일 00:00~02:00) | confirmed | indigo | 자정 넘김(이도윤): 오늘=정상·하단코너없음, 내일=배경+스트립·상단코너없음 |
| 내일 | 09:00 × 2개 (delta=0) | conf/pending | orange/indigo | N=2 동시 시작 → cellWidth stagger (~53px) |
| 내일 | 13:00 × 3개 (delta=0) | mixed | green/yellow/purple | N=3 동시 시작 → cellWidth stagger (~35px) |
| 내일 | 17:00 × 2개 (delta=20분) | conf/pending | red/blue | N=2 delta>0 → 8px stagger |
| 내일 | 20:30 × 2개 (delta=30분) | conf/cancelled | orange/indigo | N=2 delta>0 → 8px stagger |
| 모레 | 종일 | pendingPayment | orange | 단독 |
| 모레 | 10:00~12:00 | confirmed | indigo | 단독 |
| 모레 | 15:00~16:00 | confirmed | blue | 단독 (최소 높이 검증) |
| 모레 | 17:00~19:00 | cancelled | red | 단독 |
| 모레 | 20:00 × 2개 (delta=60분) | conf/pending | orange/blue | N=2 delta>0 → 8px stagger |

---

## 셀 배치 오프셋 (확정)

| 영역 | left | right | top | bottom |
|------|------|-------|-----|--------|
| 종일(AllDay) | 1 | 8 | 1 | 4 |
| 시간대(TimeGrid) | 1 | 8 | +0.5 | −1.5 |

```dart
top    = hourHeight * (start.hour + start.minute / 60) + 0.5
height = hourHeight * duration_minutes / 60 - 2.0  (clamp 1.0 이상)
```

---

## Phase 8: 스택 레이아웃 알고리즘 (구현 완료)

### 결정 사항

- **스택 방식** 채택: 뒤 셀은 전체 너비, 앞 셀이 위에 덮어쌓임
- **right=8.0 고정**: 모든 셀이 동일한 오른쪽 끝 공유 (Phase 7/Phase 8 균등분할과의 차이)
- **delta 기반 stagger**: N=2에서 시작 시간 차이에 따라 stagger 결정

### N=2 stagger 규칙

```
delta = front 셀 시작시간 − back 셀 시작시간 (분)

delta == 0 (동시 시작):
  → cellWidth stagger (= usableWidth/2, ~53px at 115px 열)
  → 이름 ~3자 표시 (겹침 구간 전체에서 이름 보장 필요)

delta > 0 (시작 시간 다름, 1분 이상):
  → _differentStartStagger = 8px 고정 (foreground strip 4px + gap 4px)
  → 비겹침 구간에서 이름 충분히 노출. 겹침 구간엔 strip만 보여도 충분.
  → back 셀 좌측 8px만 노출 (4px 채색 스트립 + 4px 배경색 gap)
  → 전화번호 가려져도 무방 (사용자 확인)
```

### N≥3 stagger 규칙

```
항상 cellWidth = usableWidth / N stagger 사용 (기존 규칙)
115px 열 기준:
  N=3: cellWidth ≈ 35px ≥ 31px → 스택 표시 (이름 1~2자)
  N=4: cellWidth ≈ 26.5px < 31px → 오버플로우 셀
```

### 알고리즘 (time_grid.dart `_computePositions`)

```
1. z 순서 정렬: 시작 빠른것 → 낮은 z, 같은 시작이면 짧은것 → 낮은 z (긴것이 위)
2. 그리디 인터벌 컬러링 → 각 이벤트에 열 인덱스(col) 배정
3. Union-Find: 겹치는 이벤트들을 같은 컴포넌트로 묶음
4. 컴포넌트별 N = max(col) + 1
5a. N=2 전용: 직접 겹치는 (col0, col1) 쌍의 최소 delta 계산
    → delta == 0: stagger = usableWidth/2
    → delta > 0: stagger = 8.0 (_differentStartStagger)
5b. 위치 계산:
    cellWidth = usableWidth / N  (오버플로우 임계값)
    cellWidth < 31px → OverflowCell
    cellWidth ≥ 31px → left = 1.0 + col × stagger, right = 8.0
    clipContent = col > 0
```

### 스택 레이아웃 시각 구조

```
col=0 (back):   |←──── 전체 너비 (right=8) ────────────────→|
col=1 (front):      |←── stagger 간격 ──→|←── right=8 까지 →|
                  ↑ back 셀 이 부분만 노출
```

- back 셀 노출 폭 = stagger
- front 셀 실제 폭 = usableWidth - stagger (N=2 cellWidth 방식) 또는 usableWidth - 8px (4px gap 방식)

### 데이터 구조

```dart
class _PositionedItem {
  // 일반 셀
  _PositionedItem.normal({required event, required left, required right, required clipContent})
  // 오버플로우 셀
  _PositionedItem.overflow({required events, required left, required right, required start, required end})

  bool get isOverflow => event == null;
  ReservationDisplayData? event;
  List<ReservationDisplayData>? overflowEvents;
  DateTime? overflowStart, overflowEnd;
  double left, right;
  bool clipContent;
}
```

### 오버플로우 셀(OverflowCell) 디자인

**색상 미확정 (사용자 결정 대기)**

추천안: **멀티컬러 스트립 + 중립 회색 배경**
- 배경: `context.tertiarySystemFill` (임시)
- 좌측 4px 스트립: 겹친 이벤트들의 foregroundColor를 균등 분할 (세로 스트라이프)
- 외곽선: 0.5px systemBackground (기존 셀과 동일)
- 내용: "N개" 텍스트 (secondaryLabel 색상) 중앙 정렬

---

## 자정 넘김 이벤트 구현 (14차)

### ReservationDisplayData 자정 넘김 필드

```dart
final bool isContinuation;   // 기본값 false
// true: 전날에서 이어지는 연속 셀 (배경+스트립만, 텍스트·아이콘 없음, 상단 코너 없음)

final bool continuesNextDay; // 기본값 false
// true: 다음날로 이어지는 시작 셀 (정상 표시, 하단 코너 없음)
```

### _eventsForDate 분할 로직

```
이벤트 start가 이 날짜인 경우:
  - end > 자정 → endTime = 자정으로 제한, continuesNextDay=true 추가 (하단 코너 없음)
  - end ≤ 자정 → 원본 그대로 추가

이벤트 start가 이전 날인 경우:
  - start < dateStart AND end > dateStart
  → startTime = dateStart, isContinuation=true 로 추가 (상단 코너 없음)
```

### ReservationCell 코너·여백 처리

`_cellBorderRadius` getter:
```dart
BorderRadius.only(
  topLeft/topRight:    isContinuation ? Radius.zero : Radius.circular(4),
  bottomLeft/bottomRight: continuesNextDay ? Radius.zero : Radius.circular(4),
)
```

`isContinuation=true`이면 콘텐츠 Row도 렌더링하지 않음.

### time_grid `_placementFor` 공식

```
topGap    = isContinuation   ? 0.0 : 0.5
bottomGap = continuesNextDay ? 0.0 : 1.5
top    = hourHeight × (start.hour + start.minute/60) + topGap
height = (hourHeight × durationMin/60 − topGap − bottomGap).clamp(1.0, ∞)
```

시각 효과: 자정 경계에서 두 셀이 코너·틈새 없이 연결되어 한눈에 이어지는 일정임을 알 수 있음.

### 바운스 시 연결 처리 (`_bounceExtension = 1000.0`)

Stack의 `clipBehavior: Clip.none`을 활용해 셀을 SizedBox(그리드) 경계 밖으로 연장.
SingleChildScrollView는 뷰포트(화면 영역) 기준으로 클리핑하므로 연장된 부분이 바운스 중 보임.

```
isContinuation   → top -= 1000, height += 1000  (그리드 위로 연장, top 바운스 시 연결)
continuesNextDay → height += 1000               (그리드 아래로 연장, bottom 바운스 시 연결)
```

---

## Phase 9: 셀 탭 인터랙션 설계 (미구현)

### 결정 사항 (2026-03-28 확정)

**일반 겹침 셀 탭 (스택 상태):**
- 누른 셀이 위로 팝업 애니메이션
- 예약 상세 모달 표시
- 탭 시 셀 색상 변화 → **TBD (사용자 결정 대기)**
- 모달 닫기 → 셀 원래 위치로 복귀 애니메이션

**오버플로우 셀 탭:**
- 겹쳐진 이벤트 목록 모달 표시 (팝업 없이 직접 모달)
- 모달에서 이벤트 선택 → 예약 상세 모달

### 구현 필요 항목 (추후)
- `GestureDetector` + `AnimatedPositioned` 또는 `Hero` 애니메이션
- 예약 상세 모달 위젯
- 오버플로우 목록 모달 위젯
- TimeGrid 내 탭 상태 관리 (StatefulWidget 전환 필요)

---

## 다음 작업 (context reset 이후)

1. **Phase 9: 셀 탭 인터랙션** — context reset 후 시작
   - `TimeGrid` → `ConsumerStatefulWidget` 전환
   - 일반 셀 탭: 팝업 애니메이션 + 예약 상세 모달
   - 오버플로우 셀 탭: 이벤트 목록 모달 → 상세 모달
   - 자정 넘김 연속 셀(`isContinuation=true`) 탭 동작 결정 필요 (원본 이벤트 모달? 탭 불가?)
   - 탭 시 셀 색상 변화 여부 TBD

2. **OverflowCell 배경 색상 확정** (디자인 결정 사항)
   - 현재: `context.tertiarySystemFill` 임시
   - 확정 후 `overflow_cell.dart` 수정

---

## 외부 의존성

```yaml
flutter_svg: ^2.2.3  # pubspec.yaml에 이미 포함
```

SVG 에셋 (`assets/images/icons/` 폴더 전체 등록됨):
- `assets/images/icons/checkmark_circle_fill.svg`
- `assets/images/icons/circle_dashed.svg`
- `assets/images/icons/circle_slash.svg`
