# 캘린더 일정 셀 구현 계획

Last Updated: 2026-03-31 (Phase 11 완료 — StoreColor 통합 + 리스트 모달 배경색)

---

## 개요

3일 캘린더의 종일(AllDay) 영역과 시간대(TimeGrid) 영역에 표시되는 예약 일정 셀(ReservationCell)을 구현합니다.
7가지 색상 테마 × 3가지 예약 상태 조합을 지원합니다.

---

## 현재 상태 (Phase 11 완료)

Phase 1~11 구현 완료.

| 파일 | 현황 |
|------|------|
| `colors.dart` | 셀 색상 21개 추가 완료 |
| `ui_constants.dart` | `defaultHourHeight=40`, `minHourHeight=36` 완료 |
| `reservation_cell.dart` | ReservationDisplayData(ReservationSummary 내장), isHighlighted 완료 |
| `overflow_cell.dart` | **삭제됨** (Phase 9에서 제거) |
| `all_day_row.dart` | ReservationDisplayData 필드 접근 수정 완료 |
| `time_grid.dart` | ConsumerStatefulWidget, 탭 인터랙션 3종, stagger 임계값 제거 완료 |
| `three_day_calendar.dart` | mock Reservation 맵, scrollToTimeTrigger listen 완료 |
| `home_calendar_controller.dart` | ScrollToTimeTrigger, PendingHighlightId provider, selectDateFromContinuation() 완료 |
| `reservation_detail_modal.dart` | 신규 — 하프 시트 플레이스홀더 (후속 수정 필요) |
| `reservation_list_modal.dart` | 신규 — N≥4 그룹 목록 모달 (후속 수정 필요) |

---

## 디자인 스펙

### 셀 외관

```
┌────────────────────────────────────┐  ← border: 0.5px, systemBackground, radius 4
│████│    아이콘  예약자명 · 예약인원  │  ← 배경: ~Background 색상 (연한 색)
│████│            010-XXXX-XXXX      │  ← 좌측 4px strip: ~Foreground 색상 (진한 색)
└────────────────────────────────────┘
  ↑
 4px 진한 스트립 (~Foreground)
```

| 항목 | 값 |
|------|-----|
| 외곽선 두께 | 0.5px |
| 외곽선 색상 | `context.systemBackground` |
| 코너 반지름 | 4 |
| 좌측 진한 스트립 너비 | 4px |
| 스트립 색상 | `~Foreground` (진한 색, 예: greenForeground #34C759) |
| 나머지 배경 | `~Background` 색상 (연한 색, 예: greenBackground #AEEABD) |
| 텍스트 / 아이콘 색상 | `~Label` 색상 |

### 셀 내부 레이아웃

- 아이콘: 라벨 영역 왼쪽에서 4px (= 셀 왼쪽에서 8px: 스트립 4 + 간격 4)
- 아이콘 ↔ 텍스트 간격: 2.5px
- 텍스트 1행: `예약자명 · 예약인원` (예: "유훈자 · 2인")
- 텍스트 2행: 전화번호 (예: "010-3109-6381")
- 텍스트 overflow: ellipsis
- 텍스트 스타일: `labelSmall` (fontSize: 10, height: 1.5, FontWeight.normal), Label 색상

### 라벨 폰트 상세 및 16px 높이 판단

**프로젝트 `labelSmall` 정의 (my_app.dart):**
```dart
labelSmall: TextStyle(
  fontSize: 10.0,
  height: 1.5,         // 라인 높이 = 10 × 1.5 = 15px
  fontWeight: FontWeight.normal,
)
```

**피그마 스펙:** 라벨 높이 16px

**Flutter 구현 판단: `labelSmall` 그대로 사용 (명시적 height 오버라이드 불필요)**

| 방식 | 라인 높이 | 권장 여부 |
|------|-----------|-----------|
| `labelSmall` (현재) | 15px | ✅ **권장** |
| `.copyWith(height: 1.6)` | 16px | 가능하지만 불필요 |
| `SizedBox(height: 16)` 래핑 | 위젯 높이 16 (라인 높이 아님) | ❌ 금지 |

이유:
- 15px vs 16px 차이는 10px 폰트에서 시각적으로 **구분 불가** (1px = 폰트 크기의 10%)
- `SizedBox(height: 16)` 방식은 라인 높이를 제어하는 게 아닌 위젯 높이를 고정하므로, 다른 텍스트 크기(접근성 설정) 적용 시 클리핑 발생
- Figma의 "높이 16"은 Pretendard 폰트의 자체 line-metrics가 16px 근방에 맞춰진 것으로, Flutter에서 `labelSmall`로 렌더링하면 시각적으로 동일하게 표현됨
- **결론: `labelSmall` 그대로 사용. 별도 height 조정 불필요.**

### 셀 배치 오프셋

**종일 영역 (AllDay):**

| 방향 | 구분선으로부터 거리 |
|------|-------------------|
| 좌 | 1px |
| 우 | 8px |
| 상 | 1px |
| 하 | 4px |

결과 셀 높이 = `allDayRowHeight(40) - 1 - 4 = 35px`

**시간대 영역 (TimeGrid):**

| 방향 | 구분선으로부터 거리 |
|------|-------------------|
| 좌 | 1px |
| 우 | 8px |
| 상 | 0.5px |
| 하 | 0.5px |

결과 셀 높이 (1시간 슬롯) = `hourHeight - 1`
→ `hourHeight = 40`(최소) 기준: 셀 높이 = 39px

### 예약 상태별 아이콘 (모두 SVG)

| 상태 | SVG 파일 | viewBox |
|------|----------|---------|
| 예약 확정 (confirmed) | `assets/images/icons/checkmark_circle_fill.svg` | - |
| 입금 대기 (pendingPayment) | `assets/images/icons/circle_dashed.svg` | 10×10 |
| 예약 취소 (cancelled) | `assets/images/icons/circle_slash.svg` | - |

모든 아이콘: `SvgPicture.asset(path, width: 12, height: 12, colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn))`

> **아이콘 크기:** SVG viewBox 비율에 따라 실제 렌더링 크기가 다를 수 있음. `fit: BoxFit.contain` 기본 적용됨. 필요시 아이콘별 크기 미세 조정.

### 색상 시스템 (21개)

**배경색 (~Background):** 셀 좌측 4px 스트립
```
redBackground   → #FF9E99   orangeBackground → #FFD599
yellowBackground→ #FFEB99   greenBackground  → #AEEABD
blueBackground  → #99CAFF   indigoBackground → #AEADEB
purpleBackground→ #D7A9EF
```

**메인색 (~Foreground):** 셀 나머지 배경
```
redForeground   → #FF3B30   orangeForeground → #FF9500
yellowForeground→ #FFCC00   greenForeground  → #34C759
blueForeground  → #007AFF   indigoForeground → #5856D6
purpleForeground→ #AF52DE
```

**라벨색 (~Label):** 텍스트 및 아이콘
```
redLabel   → #990800   orangeLabel → #995900
yellowLabel→ #997A00   greenLabel  → #207936
blueLabel  → #004999   indigoLabel → #1F1E7B
purpleLabel→ #5E1980
```

---

## 구현 단계

### Phase 1: 색상 상수 추가

**파일:** `lib/presentation/colors.dart`

21개 색상 상수 추가 (redBackground ~ purpleLabel).

### Phase 2: 줌 범위 수정

**파일:** `lib/constants/ui_constants.dart`

```dart
// 변경 전
const double defaultHourHeight = 36.0;
const double minHourHeight = 18.0;
// 변경 후
const double defaultHourHeight = 40.0;  // minHourHeight와 동기화
const double minHourHeight = 40.0;
```

> **주의:** `HomeCalendarController.build()`에서 초기 `hourHeight`는 clamp 없이 직접 state에 주입됩니다.
> `defaultHourHeight < minHourHeight`이면 앱 시작 시 hourHeight=36으로 동작하므로 두 값을 함께 변경합니다.
> 또한 `loadHourHeight` 반환 시에도 `clamp(minHourHeight, maxHourHeight)` 적용을 권장합니다.

### Phase 3: ReservationCell 위젯 구현

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart`

#### 3-1. `ReservationStatus` enum

```dart
enum ReservationStatus {
  confirmed,      // 예약 확정
  pendingPayment, // 입금 대기
  cancelled,      // 예약 취소
}
```

#### 3-2. `ReservationCellColorTheme` enum

```dart
enum ReservationCellColorTheme {
  red, orange, yellow, green, blue, indigo, purple;

  Color get backgroundColor { ... } // ~Background 색상 반환
  Color get foregroundColor { ... }  // ~Foreground 색상 반환
  Color get labelColor { ... }       // ~Label 색상 반환
}
```

#### 3-3. `ReservationDisplayData` 클래스 (presentation layer 임시 뷰 모델)

```dart
/// 예약 셀 표시용 임시 데이터 클래스.
/// TODO: 예약(Reservation) 도메인 엔티티 정의 후 교체 예정.
class ReservationDisplayData {
  const ReservationDisplayData({
    required this.reserverName,
    required this.headcount,
    required this.phoneNumber,
    required this.status,
    required this.colorTheme,
    required this.isAllDay,
    this.startTime,
    this.endTime,
  });

  final String reserverName;
  final int headcount;
  final String phoneNumber;
  final ReservationStatus status;
  final ReservationCellColorTheme colorTheme;
  final bool isAllDay;
  final DateTime? startTime; // 종일이면 null
  final DateTime? endTime;   // 종일이면 null
}
```

#### 3-4. `_StatusIcon` private 위젯

모든 상태 SVG 방식으로 통일:
```dart
SvgPicture.asset(
  _svgPath(status),
  width: 12,
  height: 12,
  colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
)

String _svgPath(ReservationStatus status) => switch (status) {
  ReservationStatus.confirmed     => 'assets/images/icons/checkmark_circle_fill.svg',
  ReservationStatus.pendingPayment => 'assets/images/icons/circle_dashed.svg',
  ReservationStatus.cancelled     => 'assets/images/icons/circle_slash.svg',
};
```

#### 3-5. `ReservationCell` 위젯

```
ClipRRect (borderRadius: 4)
└─ Stack
   ├─ Container (color: foregroundColor)       → 전체 배경
   ├─ Positioned(left:0, width:4)
   │  └─ Container(color: backgroundColor)    → 좌측 진한 스트립
   ├─ Container(decoration: border 0.5 systemBackground, radius 4)  → 외곽선 overlay
   └─ Positioned.fill
      └─ Row(crossAxisAlignment: start)
         ├─ SizedBox(width: 4)                → 스트립 우측 끝에서 시작
         ├─ Padding(top: 2)
         │  └─ _StatusIcon(size: 12)
         ├─ SizedBox(width: 2.5)
         └─ Expanded
            └─ Padding(top: 2)
               └─ Column(mainAxisSize: min, crossAxisAlignment: start)
                  ├─ Text("예약자명 · N인", labelSmall, overflow: ellipsis, maxLines: 1)
                  └─ Text("010-XXXX-XXXX", labelSmall, overflow: ellipsis, maxLines: 1)
```

### Phase 4: AllDayCell 수정

**파일:** `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

```dart
class AllDayCell extends StatelessWidget {
  const AllDayCell({super.key, required this.events});
  final List<ReservationDisplayData> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: allDayRowHeight,
      child: Stack(
        children: [
          for (final event in events)
            Positioned(
              left: 1, right: 8, top: 1, bottom: 4,
              child: ReservationCell(data: event),
            ),
        ],
      ),
    );
  }
}
```

> 다중 이벤트 겹침 처리 미구현 (스코프 아웃). TODO 주석 추가.

### Phase 5: TimeGrid 수정

**파일:** `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

```dart
// Stack children에 이벤트 추가
for (final event in events) ...[
  if (!event.isAllDay && event.startTime != null && event.endTime != null)
    Positioned(
      top: _topOffset(event.startTime!, hourHeight),
      left: 1,
      right: 8,
      height: _cellHeight(event.startTime!, event.endTime!, hourHeight)
          .clamp(1.0, double.infinity),
      child: ReservationCell(data: event),
    ),
],

// 계산 함수
double _topOffset(DateTime start, double hourHeight) =>
    hourHeight * (start.hour + start.minute / 60) + 0.5;

double _cellHeight(DateTime start, DateTime end, double hourHeight) =>
    hourHeight * end.difference(start).inMinutes / 60 - 1.0;
```

### Phase 6: ThreeDayCalendar 목업 데이터 추가

**파일:** `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

**오늘 날짜 기준 목업 이벤트 (앱 시작 시 항상 현재 날짜 근처에 표시됨):**

```dart
static List<ReservationDisplayData> _buildMockEvents() {
  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final tomorrow = today.add(const Duration(days: 1));
  final dayAfter = today.add(const Duration(days: 2));

  return [
    // 오늘 - 종일 (예약 확정, 초록)
    ReservationDisplayData(
      reserverName: '유훈자', headcount: 2,
      phoneNumber: '010-3109-6381',
      status: ReservationStatus.confirmed,
      colorTheme: ReservationCellColorTheme.green,
      isAllDay: true,
    ),
    // 오늘 - 07:00~08:30 (예약 확정, 초록)
    ReservationDisplayData(
      reserverName: '유훈자', headcount: 2,
      phoneNumber: '010-3109-6381',
      status: ReservationStatus.confirmed,
      colorTheme: ReservationCellColorTheme.green,
      isAllDay: false,
      startTime: today.add(const Duration(hours: 7)),
      endTime: today.add(const Duration(hours: 8, minutes: 30)),
    ),
    // 오늘 - 10:00~13:00 (예약 취소, 초록) → circle_slash
    ReservationDisplayData(
      reserverName: '김민준', headcount: 4,
      phoneNumber: '010-5555-1234',
      status: ReservationStatus.cancelled,
      colorTheme: ReservationCellColorTheme.green,
      isAllDay: false,
      startTime: today.add(const Duration(hours: 10)),
      endTime: today.add(const Duration(hours: 13)),
    ),
    // 내일 - 10:00~14:00 (입금 대기, 노란) → circle_dashed
    ReservationDisplayData(
      reserverName: '이서준', headcount: 3,
      phoneNumber: '010-7777-9999',
      status: ReservationStatus.pendingPayment,
      colorTheme: ReservationCellColorTheme.yellow,
      isAllDay: false,
      startTime: tomorrow.add(const Duration(hours: 10)),
      endTime: tomorrow.add(const Duration(hours: 14)),
    ),
    // 내일 - 15:00~16:00 (예약 확정, 파랑) → 짧은 셀 (1시간)
    ReservationDisplayData(
      reserverName: '박지원', headcount: 1,
      phoneNumber: '010-1234-5678',
      status: ReservationStatus.confirmed,
      colorTheme: ReservationCellColorTheme.blue,
      isAllDay: false,
      startTime: tomorrow.add(const Duration(hours: 15)),
      endTime: tomorrow.add(const Duration(hours: 16)),
    ),
    // 모레 - 종일 (입금 대기, 주황)
    ReservationDisplayData(
      reserverName: '최수아', headcount: 5,
      phoneNumber: '010-2222-3333',
      status: ReservationStatus.pendingPayment,
      colorTheme: ReservationCellColorTheme.orange,
      isAllDay: true,
    ),
    // 모레 - 13:00~15:00 (예약 취소, 보라)
    ReservationDisplayData(
      reserverName: '정하은', headcount: 2,
      phoneNumber: '010-8888-4444',
      status: ReservationStatus.cancelled,
      colorTheme: ReservationCellColorTheme.purple,
      isAllDay: false,
      startTime: dayAfter.add(const Duration(hours: 13)),
      endTime: dayAfter.add(const Duration(hours: 15)),
    ),
  ];
}

static late final _mockEvents = _buildMockEvents();

// 날짜별 필터링
List<ReservationDisplayData> _eventsForDate(DateTime date, {required bool allDay}) {
  return _mockEvents.where((e) {
    if (e.isAllDay != allDay) return false;
    if (allDay) {
      // 종일 이벤트: 날짜 비교 없이 오늘만 표시 (목업이므로 today에 고정)
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return date == today ||
             date == today.add(const Duration(days: 2)); // 모레 종일도 표시
    }
    final s = e.startTime!;
    return s.year == date.year && s.month == date.month && s.day == date.day;
  }).toList();
}
```

---

## 파일 구조 변경

```
lib/
├── presentation/
│   ├── colors.dart                           # 색상 21개 추가 (수정)
│   └── home/widgets/three_day_calendar/
│       ├── reservation_cell.dart             # 신규 (ReservationCell, enum, data class)
│       ├── all_day_row.dart                  # 수정 (events 파라미터 추가)
│       ├── time_grid.dart                    # 수정 (events 파라미터 추가)
│       └── three_day_calendar.dart           # 수정 (mock 데이터 전달)
└── constants/
    └── ui_constants.dart                     # 수정 (defaultHourHeight/minHourHeight → 40)
```

---

## 목업 데이터 검증 체크리스트

구현 완료 후 아래 항목을 시각적으로 확인:

| 확인 항목 | 기대 결과 |
|-----------|-----------|
| 오늘 종일 행 - 초록 확정 셀 | checkmark_circle_fill SVG + 초록 배경 |
| 오늘 07:00~08:30 - 초록 확정 | 1.5시간 높이 셀, 텍스트 2줄 표시 |
| 오늘 10:00~13:00 - 초록 취소 | 3시간 높이 셀, circle_slash 아이콘 |
| 내일 10:00~14:00 - 노랑 대기 | 4시간 높이 셀, circle_dashed 아이콘 |
| 내일 15:00~16:00 - 파랑 확정 | 1시간(최소) 높이 셀, 텍스트 truncation 확인 |
| 모레 종일 - 주황 대기 | 종일 행 주황 셀 |
| 모레 13:00~15:00 - 보라 취소 | 보라 색상 셀 |
| 셀 외곽선 | 0.5px, 밝은 배경에서 구분되는지 |
| 다크 모드 | 외곽선(systemBackground) 자동 적응 |
| 핀치 줌 아웃 | hourHeight=40 이하로 내려가지 않는지 |

---

## 위험 요소 및 대응

| 위험 | 대응 |
|------|------|
| 다중 이벤트 겹침 처리 없음 | 동일 시간대 다중 예약 시 겹쳐 보임 (스코프 아웃, TODO 주석) |
| `ReservationDisplayData` → 도메인 교체 | `// TODO:` 주석으로 교체 지점 명시 |
| flutter_svg SVG 색상 적용 | `ColorFilter.mode(labelColor, BlendMode.srcIn)` — SVG가 `fill="black"`이어야 함. circle_dashed.svg 확인됨 ✅ |
| defaultHourHeight 변경으로 기존 저장값 충돌 | SharedPreferences에 36이 저장된 기기: `loadHourHeight` 반환 시 clamp 적용 권장 |

---

## Phase 10: 모달 UI 버그 수정 (다음 작업)

> **Flutter 3.41.6으로 업그레이드 완료**. `showCupertinoSheet`에 `topGap`, `showDragHandle` 파라미터 사용 가능.

### showCupertinoSheet Flutter 3.41.6 현황
- `topGap`: 시트 최대 확장 시 상단 여백 (double) ✅ 사용 가능
- `showDragHandle`: Grabber pill 자동 표시 (bool) ✅ 사용 가능
- `detents` (medium/large): 여전히 미지원

### ReservationDetailModal 수정

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
1. `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가 → 너비 채움 버그 수정
2. `Column` → `SingleChildScrollView(controller: scrollController, child: Column(...))` 감쌈 → 드래그 최대화 활성화
3. `DraggableScrollableSheet`: `initialChildSize: 0.5, minChildSize: 0.5, maxChildSize: 1.0, expand: false` 유지

**iOS** (`showCupertinoSheet`):
1. `showDragHandle: true` 추가
2. `topGap`: 현재 플레이스홀더이므로 기본값 유지, 추후 입력폼 Phase에서 피그마 537px 기준 계산

**초기 높이 (미결 — 추후 입력폼 Phase에서 결정)**:
- 피그마 기준: safeArea 제외 537px (특정 입력칸이 보이는 지점)
- 현재: 50% 임시
- 추후 결정: 옵션 A(하드코딩 537px), 옵션 B(GlobalKey 동적 계산)

### ReservationListModal 수정

**Android** (`showModalBottomSheet` + `DraggableScrollableSheet`):
1. `showModalBottomSheet`에 `backgroundColor: Colors.transparent` 추가
2. `DraggableScrollableSheet(initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 1.0, expand: false)` 적용
3. `ScrollController? scrollController` 파라미터 추가 후 스크롤 위젯에 연결

**iOS** (`showCupertinoSheet`):
1. `showDragHandle: true` 추가
2. `topGap`: 화면 높이의 50% 기준 (`MediaQuery.of(context).size.height * 0.5`)

---

## 미구현 (추후 작업)

- `ReservationDetailModal` 실제 디자인 구현 (예약 상세 편집 폼) — 입력폼 Phase에서
- 실제 Firestore 데이터 연결 (mock 제거)
- Reservation 도메인 엔티티 + Riverpod 연결
