# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-03-30 (Phase 10 준비 — Flutter 3.41.6 업그레이드 반영)

---

## 현재 구현 상태

**Phase 1~9 구현 완료. 최종 코드 리뷰 APPROVED.**
**후속 수정: Android/iOS 테스트에서 모달 UI 버그 발견 — Phase 10에서 수정 예정.**

> Phase 7: 2개 이벤트 겹침 — 고정 `_overlapTopLeft=52.0` 방식 (Phase 8로 교체됨)
> Phase 8: 스택 레이아웃 + delta 기반 stagger + 오버플로우 셀 + 자정 넘김 + 바운스 연결 — **완료**
> Phase 9: 셀 탭 인터랙션 (하이라이트 + 모달) — **완료**
> Phase 10: 모달 UI 버그 수정 — **미착수 (다음 작업)**

---

## Phase 10 준비: Flutter 3.41.6 업그레이드 및 버그 분석 (2026-03-30)

### Flutter 버전 업그레이드

- 3.38.5 → **3.41.6**으로 업그레이드 완료
- `showCupertinoSheet`에 신규 파라미터 추가됨:
  - `topGap`: 시트 최대 확장 시 상단 여백 (화면 상단~시트 상단 거리, double)
  - `showDragHandle`: Grabber pill 표시 여부 (bool, true 시 자동으로 상단에 렌더링)

### 발견된 버그 목록

#### ReservationDetailModal (Android)
1. **화면 너비 미채움**: 시트가 화면 너비보다 좁게 표시됨
   - **원인**: `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 미설정
   - `DraggableScrollableSheet`의 기본 배경이 `Material`과 겹쳐 너비가 제한됨
2. **드래그 최대화 불가**: 위로 드래그해도 시트 높이가 늘어나지 않음
   - **원인**: `DraggableScrollableSheet`의 `scrollController`가 `ReservationDetailModal` 내부에 전달되고 있으나, 현재 위젯이 `Column`(스크롤 없음)이라 드래그 이벤트가 전파되지 않음
   - **해결**: `Column` → `SingleChildScrollView(controller: scrollController)` 로 감싸야 함

#### ReservationListModal (Android/iOS)
1. **최대 높이로 표시됨**: 모달이 전체화면으로 열림
   - Android: `DraggableScrollableSheet` 미적용, `showModalBottomSheet`만 단순 사용
   - iOS: `showCupertinoSheet` 기본 동작이 거의 전체화면
2. **Grabber 미표시**: Pill 핸들이 보이지 않음
   - `ReservationListModal` 위젯 내 pill Container가 없음 (현재 `Padding`으로 시작)
   - iOS: `showDragHandle: true` 미설정

### ReservationDetailModal 초기 높이 결정 미완료

- **피그마 스펙**: safeArea 제외 537px (특정 입력칸이 보이는 지점까지)
- **현재 결정**: 플레이스홀더 단계이므로 50%(`initialChildSize: 0.5`)로 임시 설정
- **추후 결정 필요**: 실제 입력폼 구현 시 아래 두 방식 중 선택
  - 옵션 A: 537px 하드코딩 → `topGap = screenHeight - safeArea.top - 537` (iOS), `initialChildSize = 537 / availableHeight` (Android)
  - 옵션 B: `GlobalKey`로 특정 입력칸 위치 파악 → 동적 계산
  - **현재 권장**: 입력폼이 없는 지금은 0.5 유지, 입력폼 Phase에서 GlobalKey 방식 검토

---

## 수정된 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/colors.dart` | 색상 21개 추가 (Background/Foreground/Label × 7) |
| `lib/constants/ui_constants.dart` | defaultHourHeight 36→40, minHourHeight 18→36 |
| `lib/presentation/providers/hour_height_preference_provider.dart` | loadHourHeight에 clamp 추가 |
| `lib/presentation/providers/home_calendar_controller.dart` | ScrollToTimeTrigger, PendingHighlightId provider 추가, selectDateFromContinuation() 메서드 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart` | ReservationDisplayData 재구성(ReservationSummary 내장), ReservationCellColorTheme/셀 ReservationStatus 제거, isHighlighted 파라미터 추가 |
| `lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart` | **삭제** (Phase 9에서 제거) |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart` | ReservationDisplayData 필드 접근 수정 |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart` | ConsumerStatefulWidget 전환, _PositionedItem 변경, stagger 임계값 제거, 탭 핸들러 3종, reservations 파라미터, pendingHighlightIdProvider watch |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart` | ReservationDisplayData 생성 로직 수정, mock Reservation 맵, scrollToTimeTrigger listen |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | **신규** — 하프 시트 플레이스홀더 (후속 수정 필요) |
| `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart` | **신규** — N≥4 그룹 목록 모달 (후속 수정 필요) |

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

## Phase 9: 셀 탭 인터랙션 (구현 완료)

### 탭 흐름별 동작

**① 일반 셀 탭 (N<4, groupEvents == null):**
- `_highlightedId` / `_selectedId` = event.id → setState (하이라이트 + z-순서 최상단)
- `showReservationDetailModal(reservations[event.id])` await
- 모달 닫힘 후 상태 초기화

**② N≥4 그룹 셀 탭 (groupEvents != null):**
- `showReservationListModal(groupEvents)` → 선택된 `ReservationSummary`
- 선택 후 하이라이트 + 상세 모달

**③ isContinuation 셀 탭:**
- `pendingHighlightIdProvider.set(event.id)` → 원본 TimeGrid 하이라이트
- `homeCalendarController.selectDateFromContinuation(originalDate)` → 날짜 이동
- `scrollToTimeTriggerProvider.trigger(originalStartTime)` → 수직 스크롤
- `showReservationDetailModal(reservations[event.id])` await
- 모달 닫힘 후 `pendingHighlightIdProvider.clear()`

### 실제 구현 vs 설계 차이

- **scrollToTimeTrigger**: 설계에서는 `ref.listen` 제안 → 구현에서는 `animateToPage.then()` 내 `ref.read()` 폴링 (경쟁 조건 방지 목적, 의도적 개선)
- **OverflowCell**: 제거됨. N≥4도 항상 스택 표시. `groupEvents` 필드로 목록 모달 연동.

### 커밋 이력 (Phase 9)

| 커밋 | 내용 |
|------|------|
| `8c386cc` | ReservationDisplayData 재구성, isHighlighted 추가 |
| `637cffa` | OverflowCell 제거, TimeGrid ConsumerStatefulWidget 전환 |
| `3cd9cab` | ReservationDetailModal, ReservationListModal 신규 |
| `7e9aa57` | 코드 품질 수정 (DateFormat 위치, Icon size, TODO) |
| `cd6955a` | TimeGrid 탭 인터랙션 3가지 흐름 |
| `1fed115` | state 누수 수정 |
| `4e19f0b` | highlightNotifier 사전 캡처 |
| `f160a24` | scrollToTimeTrigger 처리 추가 |
| `f1eb57e` | DateTime.now() 중복 정리 + 주석 보완 |

---

## 다음 작업: 모달 UI 버그 수정

### Android — ReservationDetailModal
1. `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가 → 너비 문제 해결
2. `Material` 내 `Column`을 `SingleChildScrollView(controller: scrollController, child: Column(...))`로 감쌈 → 드래그 동작 활성화
3. iOS: `showCupertinoSheet` 기본 전체화면 동작 유지 (Flutter 3.38.5에서 half-sheet 불가, `detents`/`topGap` 파라미터 없음)

### Android/iOS — ReservationListModal
1. `ReservationListModal`에 `ScrollController? scrollController` 파라미터 추가
2. 위젯 구조: `Material → SafeArea → SingleChildScrollView(controller) → Column[Grabber pill, Padding(GroupedFormContainer)]`
3. Grabber pill 추가 (36×5, `outlineVariant` 색상)
4. Android `showModalBottomSheet`에 `DraggableScrollableSheet(initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 1.0)` + `backgroundColor: Colors.transparent` 추가
5. iOS: `showCupertinoSheet` 기본 전체화면 동작 유지

### showCupertinoSheet 한계 (Flutter 3.38.5)
- `topGap`, `detents` 파라미터 없음
- 내부 `_kTopGapRatio = 0.08` 고정값 사용 (화면 높이의 8% gap)
- iOS half-sheet 구현 불가 (현재 Flutter 버전 한계)

---

## 외부 의존성

```yaml
flutter_svg: ^2.2.3  # pubspec.yaml에 이미 포함
```

SVG 에셋 (`assets/images/icons/` 폴더 전체 등록됨):
- `assets/images/icons/checkmark_circle_fill.svg`
- `assets/images/icons/circle_dashed.svg`
- `assets/images/icons/circle_slash.svg`
