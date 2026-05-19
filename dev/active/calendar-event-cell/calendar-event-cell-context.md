# 캘린더 일정 셀 - 컨텍스트 및 참조

Last Updated: 2026-05-19 (버그 수정 — 예약 셀 전화번호 하이픈 포맷 미적용)

---

## 현재 구현 상태

**Phase 1~23 구현 완료. 버그 수정 1건 추가 (2026-05-19).**

> Phase 7: 2개 이벤트 겹침 — 고정 `_overlapTopLeft=52.0` 방식 (Phase 8로 교체됨)
> Phase 8: 스택 레이아웃 + delta 기반 stagger + 오버플로우 셀 + 자정 넘김 + 바운스 연결 — **완료**
> Phase 9: 셀 탭 인터랙션 (하이라이트 + 모달) — **완료** (TimeGrid 전용, AllDayCell 빠짐)
> Phase 10: 모달 UI 버그 수정 — **완료**
> Phase 11: StoreColor 통합 + 리스트 모달 배경색 — **완료**
> Phase 23: AllDayCell 탭 인터랙션 추가 — **완료**

---

## 버그 수정: 예약 셀 전화번호 하이픈 포맷 미적용 (2026-05-19)

### 문제

`ReservationCell`의 `_buildClipContent`와 `_buildContentRow`에서 `data.summary.customerPhone`을 그대로 표시하여 `01012345678` 형식으로 출력됨.

### 원인

`phone_formatter.dart`의 `formattedPhone` 확장(`StringPhoneFormatter`)이 이미 존재했으나 `reservation_cell.dart`에서 import 및 사용 누락.

### 해결

**`reservation_cell.dart`**:
- `phone_formatter.dart` import 추가
- `data.summary.customerPhone` → `data.summary.customerPhone.formattedPhone` (두 곳: `_buildClipContent`, `_buildContentRow`)

### 영향 범위

- `TimeGrid` 일반 셀(`clipContent=false`): `_buildContentRow` 경로
- `TimeGrid` front/middle 셀(`clipContent=true`): `_buildClipContent` 경로
- `AllDayCell`: 동일 `ReservationCell` 위젯 사용 → 동시 수정됨

---

## Phase 23: AllDayCell 탭 인터랙션 추가 (2026-04-22)

### 문제

Phase 9에서 `TimeGrid`에만 탭 인터랙션을 구현했고 `AllDayCell`은 누락됨.
종일 이벤트 셀을 눌러도 `GestureDetector`가 없어 `reservation_detail_modal`이 표시되지 않았음.

### 원인 분석

- `AllDayCell`은 `StatelessWidget`으로 `ReservationCell`을 렌더링만 함
- `reservations` 파라미터(상세 모달에 전달할 `Map<String, Reservation>`) 없음
- `GestureDetector` 없음
- `isHighlighted` 상태 관리 없음

### 해결

**`all_day_row.dart`**:
- `AllDayCell` → `ConsumerStatefulWidget` 전환
- `reservations: Map<String, Reservation>` 파라미터 추가
- `_highlightedId` 로컬 상태 + `_onCellTap()` 메서드 추가
- `ReservationCell`을 `GestureDetector(onTap: _onCellTap)` 으로 감쌈
- `isHighlighted: _highlightedId == event.summary.id` 전달

**`three_day_calendar.dart`**:
- `AllDayCell(reservations: _mockReservations)` 파라미터 추가

### 설계 메모

- 종일 이벤트는 `isContinuation` / `continuesNextDay` 케이스 없음 → TimeGrid보다 단순
- N≥4 그룹 탭 (목록 모달) 미구현 — 종일 행 높이가 고정이라 overflow 처리가 필요한 상황 자체가 드물고 TODO 주석으로 처리됨
- `ConsumerStatefulWidget`을 사용하나 실제로 ref는 사용하지 않음. 향후 실데이터 연결 시 provider watch 추가 예상.

---

## Phase 21: ModalAppBar 컴포넌트화 + 하단 구분선 제거 (2026-04-01)

### 문제

`my_app.dart` AppBarTheme에 `shape: Border(bottom: BorderSide(...))` 로 앱 전역 하단 구분선이 정의됨.
기존 모달의 Theme 오버라이드가 `shape`를 덮지 않아 구분선이 모달에서도 노출됨.

### 해결

**`lib/presentation/commons/widgets/app_bar/modal_app_bar.dart`** (신규):
- `ModalAppBar` — `CustomAppBar` 래퍼 + 모달용 Theme 오버라이드 캡슐화
- `shape: const RoundedRectangleBorder()` → 테두리 없는 shape로 앱 테마 구분선 제거
- 투명 배경(`backgroundColor`, `surfaceTintColor`, `shadowColor`)도 포함
- `leading` 기본값 `SizedBox.shrink()` (Navigator 자동 back button 방지)
- `PreferredSizeWidget` 구현 (Scaffold.appBar에도 사용 가능)

```dart
// 사용법
ModalAppBar(title: '예약 목록')  // leading 없음

ModalAppBar(
  title: '예약 정보',
  leading: AppBarActionButton(label: '취소', isRegularWeight: true, onPressed: ...),
  actions: [AppBarActionButton(label: '편집', onPressed: ...)],
)
```

**`reservation_detail_modal.dart`**, **`reservation_list_modal.dart`**:
- `Theme(...)` + `CustomAppBar(...)` 중복 패턴 → `ModalAppBar(...)` 1줄로 교체

---

## Phase 20: ModalGrabber 컴포넌트화 (2026-04-01)

### 변경 사항

**`lib/presentation/commons/widgets/modal_grabber.dart`** (신규):
- `ModalGrabber` StatelessWidget 생성
- 높이 14px SizedBox 안에 36×5 pill (코너 반지름 2.5)
- 다크 모드 자동 대응: `modalGrabberDarkColor` / `modalGrabberColor`
- `isDarkMode` 판단을 위젯 내부에서 처리

**`reservation_detail_modal.dart`**, **`reservation_list_modal.dart`**:
- 인라인 Grabber 코드 (SizedBox+Center+Container 13줄) → `const ModalGrabber()` 1줄 교체
- `isDarkMode` 로컬 변수 제거

### ModalGrabber 사용법

```dart
// 모달 Column 최상단에 배치
Column(
  children: [
    const ModalGrabber(),
    CustomAppBar(...),
    Expanded(content),
  ],
)
```

---

## Phase 19: AppBarActionButton isRegularWeight + 모달 취소 버튼 통합 (2026-03-31)

### 변경 사항

**`app_bar_action_button.dart`**:
- `final bool isRegularWeight` 파라미터 추가 (기본값 `false`)
  - `false`: `FontWeight.w600` (semibold)
  - `true`: `FontWeight.normal` (regular)

**`app_bar_back_button.dart`**:
- `AppBarModalBackButton`을 원래 상태(xmark 아이콘 전용)로 롤백
  - Phase 16~18에서 추가한 `label`, `OverflowBox` 관련 코드 전부 제거
  - `AppBarModalBackButton`은 xmark 아이콘 버튼으로만 사용

**`reservation_detail_modal.dart`**:
- `import app_bar_back_button.dart` 제거
- `leading: AppBarModalBackButton(label: '취소')` → `leading: AppBarActionButton(label: '취소', isRegularWeight: true)`

### AppBarActionButton 사용 패턴

```dart
// semibold (기본) — '편집', '저장' 등 주요 액션
AppBarActionButton(label: '편집', onPressed: () {})

// regular — '취소' 등 보조 액션
AppBarActionButton(label: '취소', isRegularWeight: true, onPressed: () => Navigator.pop(context))
```

### 최종 구조 비교 (업데이트)

| 요소 | 리스트 모달 | 세부 모달 |
|------|------------|---------|
| 좌측 버튼 | 없음 | `AppBarActionButton('취소', isRegularWeight: true)` |
| 우측 버튼 | 없음 | `AppBarActionButton('편집')` (semibold) |

### AppBarModalBackButton 용도 확정

xmark 아이콘 닫기 버튼 전용. 텍스트 취소 버튼은 `AppBarActionButton(isRegularWeight: true)` 사용.

---

## Phase 18: AppBarModalBackButton — OverflowBox로 tight 제약 탈출 (2026-03-31) ← 롤백됨 (Phase 19)

### 문제

`AppBar.leading`은 내부적으로 `_AppBarLayout.performLayout()`에서 `BoxConstraints.tightFor(width: leadingWidth, height: toolbarHeight)`를 child에 강제 적용.

- `leadingWidth: 56`(기본): `TextButton` ripple = 56dp (너무 작음)
- `leadingWidth: 88`(Phase 17 시도): `TextButton` ripple = 88dp (너무 큼, button이 우측으로 치우침)

어떤 `leadingWidth` 값을 써도 `TextButton`이 그 폭으로 강제됨.

### 해결책: OverflowBox

`OverflowBox`는 부모의 tight 제약을 무시하고 자식에게 별도의 제약을 제공. `maxWidth: double.infinity`로 unconstrained를 주면 `TextButton`이 자연 크기로 렌더링됨.

```dart
OverflowBox(
  maxWidth: double.infinity,
  alignment: Alignment.centerLeft,
  child: TextButton(...),
)
```

- `TextButton` 자연 크기 ≈ `AppBarActionButton("편집")`과 동일 → ripple 크기 일치 ✅
- `Alignment.centerLeft`: leading 영역(x=0)에 left-aligned로 배치 → 좌측 여백 자연스럽게 유지 ✅
- 자연 크기(~68dp)가 leadingWidth(56dp)보다 크면 title 방향으로 ~12dp overflow — `_AppBarLayout`이 clip하지 않아 시각적으로 정상 표시

### 변경 사항

**`app_bar_back_button.dart`**:
- label 분기: `TextButton` → `OverflowBox(maxWidth: infinity, alignment: centerLeft, child: TextButton(...))`

**`reservation_detail_modal.dart`**:
- `CustomAppBar(leadingWidth: 88, ...)` → `leadingWidth` 제거

**`custom_app_bar.dart`**:
- Phase 17에서 추가한 `leadingWidth` 파라미터 제거 (해결책이 잘못된 방향이었음)

### 영향 범위

- `AppBarNaviBackButton` (일반 뒤로 가기): `OverflowBox` 미적용, 변경 없음 ✅
- `AppBarModalBackButton(label: null)` (xmark 아이콘): 변경 없음 ✅
- iOS: `OverflowBox`는 플랫폼 무관한 Flutter 위젯 — 동일 동작 ✅

---

## Phase 17: CustomAppBar leadingWidth 파라미터 추가 (2026-03-31) ← 롤백됨

Phase 18에서 롤백. `leadingWidth`를 조절해도 TextButton이 강제 폭으로 렌더링되어 근본 문제 미해결.

---

## Phase 16: AppBarModalBackButton label 파라미터 추가 (2026-03-31)

### 변경 사항

**`lib/presentation/commons/widgets/app_bar/app_bar_back_button.dart`**:
- `AppBarModalBackButton`에 `final String? label` 파라미터 추가
- `label != null`이면 xmark 아이콘 대신 `TextButton`으로 렌더링
  - 스타일: `textTheme.titleLarge?.copyWith(fontWeight: FontWeight.normal, color: colorScheme.primary)`
  - `isEnabled = false`이면 color를 `quaternaryLabel`로 변경
- 기존 xmark 아이콘 동작은 `label == null`일 때 그대로 유지

```dart
// label 있을 때
TextButton(
  onPressed: isEnabled ? onPressed : null,
  child: Text(
    label!,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.normal,
      color: isEnabled ? colorScheme.primary : context.quaternaryLabel,
    ),
  ),
)
```

> ⚠️ **textStyle 결정**: 초기 `bodyMedium`으로 구현했으나 사용자가 `titleLarge`로 직접 수정. `titleLarge + FontWeight.normal`이 모달 AppBar '취소' 버튼의 확정 스타일.

**`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`**:
- `leading: AppBarActionButton(label: '취소', ...)` → `leading: AppBarModalBackButton(label: '취소', ...)`로 교체
- `import app_bar_back_button.dart` 추가
- `import app_bar_action_button.dart`는 유지 ('편집' 버튼에 여전히 사용)

### 최종 구조 비교 (업데이트)

| 요소 | 리스트 모달 | 세부 모달 |
|------|------------|---------|
| 시트 기본 배경 | `showModalBottomSheet(backgroundColor: systemGroupedBackground)` | `Material(color: systemGroupedBackground)` |
| AppBar 배경 | transparent (systemGroupedBackground 투과) | transparent (systemGroupedBackground 투과) |
| 좌측 버튼 | 없음 (`SizedBox.shrink()`) | `AppBarModalBackButton(label: '취소')` |
| 우측 버튼 | 없음 | `AppBarActionButton('편집')` |

### AppBarModalBackButton 사용 패턴

```dart
// 텍스트 취소 버튼 (모달 좌측)
AppBarModalBackButton(
  label: '취소',
  onPressed: () => Navigator.pop(context),
)

// 기존 xmark 아이콘 버튼 (label 미지정 시 기본 동작)
AppBarModalBackButton(
  onPressed: () => Navigator.pop(context),
)
```

---

## Phase 15: ModalBodyPadding 컴포넌트화 (2026-03-31)

### 신규 파일

**`lib/presentation/commons/widgets/modal_body_padding.dart`**:
```dart
class ModalBodyPadding extends StatelessWidget {
  const ModalBodyPadding({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      horizontalPadding, 16, horizontalPadding, 8,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(padding: padding, child: child),
    );
  }
}
```

### 설계 의도

- `SafeArea(top: false)`: 모달에서 상단 safe area는 AppBar가 담당하므로 하단/측면만 처리
- 기본 padding `fromLTRB(16, 16, 16, 8)`: 리스트형 모달의 표준 여백
  - 좌우: `horizontalPadding`(16) — 앱 전체 수평 패딩 상수
  - 상단: 16 — AppBar 아래 첫 콘텐츠와의 간격
  - 하단: 8 — 리스트 마지막 항목과 홈 인디케이터 사이 최소 여백
- `padding` 파라미터로 모달별 커스터마이징 가능

### 사용법

```dart
// 기본값 사용 (리스트 모달)
ModalBodyPadding(
  child: GroupedFormContainer(children: [...]),
)

// 커스텀 padding
ModalBodyPadding(
  padding: EdgeInsets.all(24),
  child: ...,
)
```

---

## Phase 14: 모달 AppBar 투명 배경 + 14px 간격 + 취소 버튼 (2026-03-31)

### 변경 사항

**두 모달 공통**:
- Grabber 구조: `Padding(only(top:6), Center(pill))` → `SizedBox(height:14, Center(pill))`
  - 이전: 6px top padding + 5px pill + 약간의 하단 여백 = ~17px
  - 이후: 14px SizedBox, pill은 수직 중앙 (y=4.5~9.5)
- AppBar 투명화: `CustomAppBar`를 `Theme` 래퍼로 감싸 `appBarTheme.backgroundColor/surfaceTintColor/shadowColor = transparent` 적용

**리스트 모달**:
- `showModalBottomSheet(backgroundColor: systemGroupedBackground)` 유지
- `ColoredBox` 제거 (시트 전체가 이미 systemGroupedBackground이므로 불필요)
- AppBar 투명 → systemGroupedBackground가 배경으로 투과

**세부 모달**:
- `Material()` → `Material(color: context.systemGroupedBackground)`
  - iOS `showCupertinoSheet`는 자체 배경을 제공하지 않으므로 Material이 배경 담당
  - Android `showModalBottomSheet`는 자체 Material이 있지만 inner Material로 덮음
- `leading: AppBarActionButton(label: '취소', onPressed: () => Navigator.pop(context))` 추가 (→ Phase 16에서 `AppBarModalBackButton(label: '취소')`로 교체됨)

### 모달 AppBar 투명화 패턴

```dart
Theme(
  data: Theme.of(context).copyWith(
    appBarTheme: Theme.of(context).appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
  ),
  child: CustomAppBar(title: '...', leading: ..., actions: [...]),
)
```

`CustomAppBar`가 `backgroundColor`를 직접 노출하지 않으므로 Theme 오버라이드 방식 사용.
`CustomAppBar` 자체의 `surfaceTintColor: Platform.isIOS ? transparent : null` 설정은 Theme 오버라이드와 독립적으로 적용됨.

### 최종 구조 비교

| 요소 | 리스트 모달 | 세부 모달 |
|------|------------|---------|
| 시트 기본 배경 | `showModalBottomSheet(backgroundColor: systemGroupedBackground)` | `Material(color: systemGroupedBackground)` |
| AppBar 배경 | transparent (systemGroupedBackground 투과) | transparent (systemGroupedBackground 투과) |
| 좌측 버튼 | 없음 (`SizedBox.shrink()`) | `AppBarModalBackButton(label: '취소')` |
| 우측 버튼 | 없음 | `AppBarActionButton('편집')` |

---

## Phase 13: AppBarActionButton + 리스트 모달 배경색 분리 (2026-03-31)

### 변경 사항

**`reservation_detail_modal.dart`**:
- `TextButton(child: Text('편집'))` → `AppBarActionButton(label: '편집', onPressed: () {})`
- `import app_bar_action_button.dart` 추가

**`reservation_list_modal.dart`**:
- `showModalBottomSheet`에서 `backgroundColor: context.systemGroupedBackground` 제거
- `Expanded` 자식을 `ColoredBox(color: context.systemGroupedBackground, child: ...)` 로 감쌈

### 배경색 분리 구조 (확정)

```
showModalBottomSheet (backgroundColor: 기본 surface)
└─ Column
   ├─ Grabber           → surface 색 (AppBar와 동일)
   ├─ CustomAppBar      → surface 색
   └─ Expanded
      └─ ColoredBox(systemGroupedBackground)
         └─ ScrollView → SafeArea → Padding → GroupedFormContainer
```

**왜 이렇게 해야 하나**:
- `showModalBottomSheet`의 `backgroundColor`는 DraggableScrollableSheet 전체(Grabber 포함)에 적용됨
- Grabber 영역까지 systemGroupedBackground가 되면 AppBar 위에 회색 띠가 생김
- ColoredBox로 Expanded 영역만 색상 지정 → Grabber+AppBar는 surface, 콘텐츠는 systemGroupedBackground

### AppBarActionButton 사용법

```dart
AppBarActionButton(
  label: '편집',
  onPressed: () { /* TODO */ },  // null이면 비활성(quaternaryLabel 색)
)
```

---

## Phase 12: 모달 AppBar + 인원 수 + stagger overflow 목데이터 (2026-03-31)

### 변경 사항

**`reservation_list_modal.dart`**:
- `CustomAppBar(title: '예약 목록', leading: const SizedBox.shrink())` 추가 (Grabber 아래, content 위)
- 고객명 표시: `'${customerName}'` → `'${customerName} · ${headCount}인'` (예약 셀과 동일 형식)
- `import custom_app_bar.dart` 추가

**`reservation_detail_modal.dart`**:
- `CustomAppBar(title: '예약 정보', leading: SizedBox.shrink(), actions: [TextButton('편집')])` 추가
- iOS `showCupertinoSheet`에서 `showDragHandle: true` 제거 — 위젯 내 Grabber와 겹치지 않도록
- `import custom_app_bar.dart` 추가

**`three_day_calendar.dart`**:
- e24~e27 목데이터 추가 (모레 12:00~15:00 슬롯, 20분 stagger)
- 설계 의도: 시작 시간이 다른 이벤트들이 순차적으로 겹쳐서 N=4 overflow가 되는 시나리오
  - 기존 e03~e06 (오늘 10:00, 모두 동시 시작 delta=0)과의 차이를 보여줌
  - 13:00에 4개 동시 활성 → max_col=3, N=4, cellWidth≈26px < 31px → overflow ✅

### stagger overflow 알고리즘 동작 설명

```
e24: 12:00~14:00 → col 0
e25: 12:20~14:20 → [e24 겹침] → col 1
e26: 12:40~14:40 → [e24, e25 겹침] → col 2
e27: 13:00~15:00 → [e24, e25, e26 겹침] → col 3
N = max_col+1 = 4, cellWidth = usableWidth/4 ≈ 26.5px < 31px → overflow
```

### CustomAppBar 모달 사용 패턴

`CustomAppBar`는 `PreferredSizeWidget` + `AppBar` 래퍼이지만, `Column` 안에서도 직접 사용 가능.
- `leading: const SizedBox.shrink()` → Navigator back button 자동 추가 방지 (autoImplyLeading은 AppBar 내부에서 leading이 non-null이면 무시)
- 모달에서는 Scaffold 없이 Column([Grabber, CustomAppBar, Expanded(content)]) 구조 사용

### 모달 헤더 구조 (공통)

```
Column(
  Padding(top:6) → Grabber 36×5
  CustomAppBar(title, leading: SizedBox.shrink(), [actions])
  Expanded(ScrollView → content)
)
```

---

## Phase 11: StoreColor 통합 + 리스트 모달 배경색 (2026-03-31)

### 변경 사항

**`lib/presentation/colors.dart`**:
- 예약 셀 색상 상수 21개 (`redBackground` ~ `purpleLabel`) **전면 삭제**
- `ReservationCell`이 이미 `StoreColor` enum의 `backgroundColorValue`/`foregroundColorValue`/`labelColorValue`를 사용하고 있어 상수가 불필요했음 (아무 곳에서도 참조 없음 확인)

**`lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`**:
- `showModalBottomSheet`에 `backgroundColor: context.systemGroupedBackground` 추가
- `GroupedFormContainer`는 이미 사용 중 (`secondarySystemGroupedBackground` 배경의 카드 컨테이너)
- 모달 배경(systemGroupedBackground) + 카드 배경(secondarySystemGroupedBackground) 계층 구조로 iOS 설정 앱 스타일 구현

### 색상 구조 (확정)

예약 색상의 진원지는 `lib/domain/enums/store_color.dart`의 `StoreColor` enum:
```dart
// 색상값 접근
Color(storeColor.backgroundColorValue)  // 연한 배경 (셀 나머지 배경)
Color(storeColor.foregroundColorValue)  // 진한 색 (좌측 4px 스트립)
Color(storeColor.labelColorValue)       // 어두운 라벨 (텍스트/아이콘)
```
`colors.dart`에는 모달/소셜로그인 관련 상수만 남음.

---

## Phase 10 구현 결과 (2026-03-30)

### Flutter 버전 업그레이드

- 3.38.5 → **3.41.6**으로 업그레이드 완료
- `showCupertinoSheet`에 신규 파라미터 추가됨:
  - `topGap`: 시트 최대 확장 시 상단 여백 **비율** (0.0~0.9). `_kTopGapRatio = 0.08`이 기본값.
    - ⚠️ 픽셀 값이 아님. `topGap: 0.5`이면 화면 상단 50%를 비워두고 하단 50%를 시트가 차지.
    - assert: `topGap >= 0.0 && topGap <= 0.9` — 이 범위를 벗어나면 debug 모드에서 assertion 오류 발생 (모달 미표시)
  - `showDragHandle`: Grabber pill 표시 여부 (bool)

### 최종 구현 구조

**파일**: `reservation_detail_modal.dart`, `reservation_list_modal.dart`

#### 공통 모달 스타일 상수 (`colors.dart`, `ui_constants.dart`)

| 상수                      | 위치                            | 값                            |
| ----------------------- | ----------------------------- | ---------------------------- |
| `modalGrabberColor`     | `presentation/colors.dart`    | `Color(0xFFB5B5BB)`          |
| `modalGrabberDarkColor` | `presentation/colors.dart`    | `Color(0xFF585858)`          |
| `modalBarrierColor`     | `presentation/colors.dart`    | `Color(0x33000000)` — 20% 검정 |
| `modalTopCornerRadius`  | `constants/ui_constants.dart` | `10.0`                       |

#### iOS 스타일 커스텀 Grabber

`showDragHandle: true` 대신 위젯 내부에 직접 렌더링:
```dart
final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

Padding(
  padding: const EdgeInsets.only(top: 6),
  child: Center(
    child: Container(
      width: 36, height: 5,
      decoration: BoxDecoration(
        color: isDarkMode ? modalGrabberDarkColor : modalGrabberColor,
        borderRadius: BorderRadius.circular(2.5),
      ),
    ),
  ),
),
```

#### showModalBottomSheet 공통 파라미터

```dart
showModalBottomSheet(
  isScrollControlled: true,
  useSafeArea: true,
  barrierColor: modalBarrierColor,
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(modalTopCornerRadius)),
  ),
  ...
)
```

#### ReservationDetailModal (현재 상태)

**Android**:
- `showModalBottomSheet(isScrollControlled: true, useSafeArea: true)` + 모달 스타일 상수 적용 (`barrierColor`, `shape`, `clipBehavior`)
- `DraggableScrollableSheet(initial: 0.5, min: 0.3, max: 1.0, snap: true, snapSizes: [0.5, 1.0], expand: false)`
- 위젯 루트: `Material(Column([커스텀 Grabber, Expanded(SingleChildScrollView)]))`  — `reservation_list_modal`과 동일한 구조

**iOS**:
- `showCupertinoSheet(showDragHandle: true)` — `topGap` 미설정 (기본값 0.08 ≈ 화면 92% 차지)
- 추후 입력폼 구현 Phase에서 `topGap` 설정 필요 (피그마 기준 safeArea 제외 537px → 비율 계산)

> **분기 유지 결정**: 입력폼 구현 시 높이 조절이 어려울 경우 `showModalBottomSheet`로 통합 검토.

#### ReservationListModal (최종 상태)

iOS/Android 통합 (`showModalBottomSheet` 단일 구현):
- 커스텀 Grabber (36×5, `modalGrabberColor`, `modalGrabberDarkColor`, top:6)
- `barrierColor: modalBarrierColor` (20% 검정 scrim)
- `shape`: 상단 코너 `modalTopCornerRadius`
- `DraggableScrollableSheet(initial: 0.5, min: 0.3, max: 1.0, snap: true, snapSizes: [0.5, 1.0], expand: false)`
- `scrollController` → `SingleChildScrollView` 연결

#### StoreAddressInputScreen 주소 검색 모달 (최종 상태)

iOS/Android 플랫폼 분기 유지:
- **iOS**: `showCupertinoSheet(enableDrag: false)` — native 시트 그대로 사용
- **Android**: `showModalBottomSheet(isDismissible: false, enableDrag: false)` + 커스텀 Grabber + `modalBarrierColor` + `modalTopCornerRadius`
  - `Column([grabber, Expanded(KpostalView)])` 구조

#### 중요 설계 메모

- **"절반(0.5)"은 임시값**: 실제로는 예약 입력폼의 특정 필드까지 보이는 높이. 입력폼 구현 Phase에서 교체.
- **iOS topGap 버그 이력**: 초기에 `topGap: MediaQuery.of(context).size.height * 0.5` (≈406) 사용 → assert 범위(0.0~0.9) 초과로 debug 모드에서 모달 미표시. 수정: `topGap: 0.5` (비율)
- **iOS detent**: Flutter는 아직 `UISheetPresentationController.detents` API 미지원. `topGap`은 최대 확장 높이만 제어하며 중간 snap 위치 없음. Flutter 업데이트 후 재검토.
- **리스트 모달 scrim**: `showCupertinoSheet`로는 scrim 구현 불가 (`barrierColor` 하드코딩, blocking ModalBarrier가 GestureDetector 차단, `removeRoute`는 exit 애니메이션 없음). `showModalBottomSheet`로 iOS/Android 통합 → 내장 scrim/dismiss/동기화 애니메이션 활용.
- **iOS 투명 배경 이슈**: `showCupertinoSheet`의 `buildContent`는 `ClipRSuperellipse`로 클리핑만 하며 배경색을 제공하지 않음. 콘텐츠 위젯이 `Material` 또는 배경 위젯을 직접 제공해야 함. `showModalBottomSheet`는 자체 Material 배경을 제공하므로 불필요.

### ReservationDetailModal 초기 높이 결정 미완료 (추후)

- **피그마 스펙**: safeArea 제외 537px (추후 입력폼에서 특정 입력칸까지 보이는 높이)
- **현재**: 50% 임시
- **추후 결정**: 옵션 A(537px 하드코딩) vs 옵션 B(GlobalKey 동적 계산)

### Android detent 동작 구현 방법

`DraggableScrollableSheet` 파라미터:
```dart
snap: true,
snapSizes: const [0.5, 1.0],  // 50%, 100% 두 단계로 스냅
```
- 50%↔100% 사이를 드래그하면 가까운 스냅 포인트로 자동 이동 (iOS detent 유사 동작)

---

## 수정된 파일 목록

| 파일                                                                               | 변경 내용                                                                                                                        |
| -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `lib/presentation/colors.dart`                                                   | 색상 21개 추가 (Background/Foreground/Label × 7), `modalGrabberColor`, `modalGrabberDarkColor`,`modalBarrierColor` 추가             |
| `lib/constants/ui_constants.dart`                                                | defaultHourHeight 36→40, minHourHeight 18→36, `modalTopCornerRadius` 추가                                                      |
| `lib/presentation/providers/hour_height_preference_provider.dart`                | loadHourHeight에 clamp 추가                                                                                                     |
| `lib/presentation/providers/home_calendar_controller.dart`                       | ScrollToTimeTrigger, PendingHighlightId provider 추가, selectDateFromContinuation() 메서드 추가                                     |
| `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart`         | ReservationDisplayData 재구성(ReservationSummary 내장), ReservationCellColorTheme/셀 ReservationStatus 제거, isHighlighted 파라미터 추가   |
| `lib/presentation/home/widgets/three_day_calendar/overflow_cell.dart`            | **삭제** (Phase 9에서 제거)                                                                                                        |
| `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`              | ConsumerStatefulWidget 전환, reservations 파라미터 추가, GestureDetector + _onCellTap + _highlightedId 추가 (Phase 23)              |
| `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`                | ConsumerStatefulWidget 전환, _PositionedItem 변경, stagger 임계값 제거, 탭 핸들러 3종, reservations 파라미터, pendingHighlightIdProvider watch |
| `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`       | ReservationDisplayData 생성 로직 수정, mock Reservation 맵, scrollToTimeTrigger listen                                              |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | **신규** — 하프 시트 플레이스홀더, iOS `showCupertinoSheet` / Android `showModalBottomSheet` + 커스텀 Grabber + 모달 상수 적용                    |
| `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`   | **신규** — N≥4 그룹 목록 모달, iOS/Android 통합 `showModalBottomSheet`, 커스텀 Grabber                                                    |
| `lib/presentation/commons/store_input/screens/store_address_input_screen.dart`   | iOS `showCupertinoSheet` 유지, Android `showModalBottomSheet` + 커스텀 Grabber + 모달 상수 적용                                         |

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

---

## 외부 의존성

```yaml
flutter_svg: ^2.2.3  # pubspec.yaml에 이미 포함
```

SVG 에셋 (`assets/images/icons/` 폴더 전체 등록됨):
- `assets/images/icons/checkmark_circle_fill.svg`
- `assets/images/icons/circle_dashed.svg`
- `assets/images/icons/circle_slash.svg`
