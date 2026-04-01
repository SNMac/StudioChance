# 예약 수정 모달 구현 계획

Last Updated: 2026-04-01

---

## 개요

예약 상세 모달의 "편집" 버튼을 탭하면 열리는 **예약 수정 모달(half-sheet)**을 구현한다.  
기존 `reservation_detail_modal.dart` 구조(ModalGrabber + ModalAppBar + 스크롤 콘텐츠)와 동일한 패턴을 따른다.

---

## 현재 상태

- `reservation_detail_modal.dart`: 플레이스홀더 (표시 로직만, 실제 폼 없음)
- `reservation_edit_modal.dart`: 미존재
- `Reservation` 도메인 엔티티: 모든 필드 정의 완료
- 공용 입력 컴포넌트: `TitleTextField`, `TitlePopupButton`, `TitleSwitchButton`, `TitleDateTimeButton`, `TitleNavigationButton`, `MemoTextField`, `GroupedFormContainer` 모두 존재

---

## 화면 구조 (피그마 기준)

```
┌──────────────────────────────┐
│  ─────  (ModalGrabber)       │
│  취소   예약 수정   완료       │  ← ModalAppBar
├──────────────────────────────┤
│  [GroupedFormContainer #1]   │
│    예약 점포  ● 1호점 ↕       │
│    예약 상태  예약 확정 ↕      │
│                              │
│  [GroupedFormContainer #2]   │
│    예약자명         String    │
│    인원             Int       │
│    연락처           String    │
│    메모 (0/200)              │
│                              │
│  [GroupedFormContainer #3]   │
│    하루종일          ○       │
│    입실 일시  2025.12.11 16:00│
│    퇴실 일시  2025.12.11 18:00│
│                              │
│  [GroupedFormContainer #4]   │
│    예약 플랫폼  네이버 예약 ↕  │
│    결제 방식   현금결제 ↕      │
│    요금                 Int  │
│    추가 요금/할인       Int   │
│  [footer: 할인 안내 텍스트]   │
│                              │
│  [GroupedFormContainer #5]   │
│  [header: n번째 예약입니다.]  │
│    입금 안내문           >   │
│    확정 안내문           >   │
└──────────────────────────────┘
```

---

## 피그마 상세 스펙

### AppBar
| 요소 | 값 |
|------|-----|
| leading | `AppBarActionButton(label: '취소', isRegularWeight: true)` |
| title | '예약 수정' |
| trailing | `AppBarActionButton(label: '완료')` — 유효성 충족 시 활성 |

### 섹션 1 — 기본 정보 (GroupedFormContainer)
| 행 | 위젯 | 데이터 |
|----|------|--------|
| 예약 점포 | `TitlePopupButton<StoreSummary>` | 컬러 dot + 점포명 |
| 예약 상태 | `TitlePopupButton<ReservationStatus>` | displayName 표시 |

### 섹션 2 — 예약자 정보 (GroupedFormContainer)
| 행 | 위젯 | 데이터 / 키보드 |
|----|------|----------------|
| 예약자명 | `TitleTextField` | text |
| 인원 | `TitleTextField` | number, 양수 정수, `FilteringTextInputFormatter.digitsOnly` |
| 연락처 | `TitleTextField` | phone (`TextInputType.phone`) |
| 메모 | `MemoTextField` | maxLength: 200, `LengthLimitingTextInputFormatter(200)` |

### 섹션 3 — 일시 정보 (GroupedFormContainer)
| 행 | 위젯 | 비고 |
|----|------|------|
| 하루종일 | `TitleSwitchButton` | ON시 시간 선택기 숨김 |
| 입실 일시 | `TitleDateTimeButton` | mode: `dateAndTime`, 하루종일=ON → `date`만 |
| 퇴실 일시 | `TitleDateTimeButton` | mode: `dateAndTime`, 하루종일=ON → `date`만 |

> **하루종일 ON 동작**: `startTime`은 날짜만(자정 00:00), `endTime`은 날짜+23:59 → `isAllDay: true`로 저장.  
> `TitleDateTimeButton`의 `content` 포맷도 날짜 전용으로 전환.

### 섹션 4 — 결제 정보 (GroupedFormContainer)
| 행 | 위젯 | 옵션 / 키보드 |
|----|------|--------------|
| 예약 플랫폼 | `TitlePopupButton<String>` | `reservationPlatforms` 상수 |
| 결제 방식 | `TitlePopupButton<String>` | `paymentMethods` 상수 |
| 요금 | `TitleTextField` | number, 비음수, `digitsOnly` |
| 추가 요금/할인 | `TitleTextField` | 부호 있는 정수, `SignedIntFormatter` (신규) |

**footer** (GroupedFormContainer footer 파라미터):
```
할인인 경우 -[값]을 입력해주세요
```
스타일: `footnote` 또는 `labelSmall`, color: `context.secondaryLabel`, padding: `EdgeInsetsDirectional.fromLTRB(16, 8, 16, 0)`

### 섹션 5 — 안내문 (GroupedFormContainer)
**header** (GroupedFormContainer header 파라미터):
```
n번째 예약입니다.
```
스타일: `bodyMedium`, color: `context.secondaryLabel`, padding: `EdgeInsetsDirectional.fromLTRB(16, 0, 16, 8)`

| 행 | 위젯 | 비고 |
|----|------|------|
| 입금 안내문 | `TitleNavigationButton` | onPressed: TODO (미구현) |
| 확정 안내문 | `TitleNavigationButton` | onPressed: TODO (미구현) |

---

## 완료 버튼 활성화 조건

```dart
bool get isValid =>
    customerName.trim().isNotEmpty &&
    headCount > 0 &&
    (isAllDay || startTime.isBefore(endTime));
```

---

## 신규 파일 목록

```
lib/
├── constants/
│   └── data_constants.dart                           # 수정 — 플랫폼/결제수단 상수 추가
├── presentation/
│   ├── commons/widgets/
│   │   ├── safe_area_with_padding.dart               # 수정 — top 파라미터 추가
│   │   └── modal_body_padding.dart                   # 삭제
│   └── home/
│       └── widgets/
│           └── three_day_calendar/
│               ├── reservation_list_modal.dart        # 수정 — ModalBodyPadding → SafeAreaWithPadding
│               └── reservation_edit_modal.dart        # 신규
```

> **컨트롤러 별도 파일 불필요**: 모달 자체가 단일 인스턴스이므로 `ConsumerStatefulWidget`의 State 내부에서 폼 상태를 직접 관리한다. Riverpod provider로 분리하면 `build_runner` 재실행 및 파일 증가가 생겨 이득 없음.

---

## 선행 정리: ModalBodyPadding 제거

> **승인 대기 중.** Phase 0으로 먼저 처리 후 본 구현 진행.

### 배경

`ModalBodyPadding`은 Phase 15(calendar-event-cell)에서 `reservation_list_modal.dart`의 중복 패턴을 추출해 만든 위젯이다.  
그러나 `SafeAreaWithPadding`과 역할이 거의 동일하고, 사용처가 1곳뿐이어서 유지 비용 대비 가치가 없다.

### 변경 내용

| 파일 | 변경 |
|------|------|
| `safe_area_with_padding.dart` | `top: bool = true` 파라미터 추가 |
| `reservation_list_modal.dart` | `ModalBodyPadding` → `SafeAreaWithPadding(top: false, padding: fromSTEB(16,16,16,8))` |
| `modal_body_padding.dart` | 삭제 |

### 영향 범위

- `SafeAreaWithPadding`의 기존 호출부는 `top: true`가 기본값이므로 **동작 변화 없음**
- `ModalBodyPadding`의 유일한 사용처인 `reservation_list_modal.dart`만 수정

---

## 재사용 기존 컴포넌트 목록

| 컴포넌트 | 파일 | 변경 여부 |
|---------|------|-----------|
| `ModalGrabber` | `modal_grabber.dart` | 없음 |
| `ModalAppBar` | `modal_app_bar.dart` | 없음 |
| `AppBarActionButton` | `app_bar_action_button.dart` | 없음 |
| `GroupedFormContainer` | `grouped_form_container.dart` | 없음 |
| `TitleTextField` | `title_text_field.dart` | 없음 |
| `TitlePopupButton` | `title_popup_button.dart` | 없음 |
| `TitleSwitchButton` | `title_switch_button.dart` | 없음 |
| `TitleDateTimeButton` | `title_date_time_button.dart` | 없음 |
| `TitleNavigationButton` | `title_navigation_button.dart` | 없음 |
| `MemoTextField` | `memo_text_field.dart` | 없음 |
| `SafeAreaWithPadding` | `safe_area_with_padding.dart` | 없음 |

---

## 신규 로직 / 컴포넌트

### SignedIntFormatter (인라인)
추가 요금/할인 필드는 음수 허용. `TitleTextField`에 `inputFormatters` 파라미터로 전달:

```dart
// 맨 앞 '-' 허용 + 숫자만
FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
```

### 날짜/시간 포맷 헬퍼
`TitleDateTimeButton`의 `content` 파라미터에 전달할 문자열 포맷:
- 날짜+시간: `'yyyy. MM. dd. (요일) HH:mm'`
- 날짜만(하루종일): `'yyyy. MM. dd. (요일)'`

```dart
// lib/presentation/commons/extensions/time_formatter.dart에 추가 또는 인라인 사용
String _formatDateTime(DateTime dt, {bool dateOnly = false}) { ... }
```

---

## 모달 표시 함수

```dart
Future<void> showReservationEditModal(
  BuildContext context, {
  required Reservation reservation,
  required List<StoreSummary> availableStores,  // 점포 선택 목록
  required void Function(Reservation) onSaved,  // 완료 콜백
})
```

> `onSaved` 콜백으로 저장 책임을 호출자에게 위임. 모달은 UI/상태만 담당.

---

## 데이터 흐름

```
Reservation (기존 데이터)
    ↓ (initState에서 초기화)
_State {controllers, 로컬 상태}
    ↓ (완료 탭)
onSaved(Reservation) → 호출자에서 Use Case 실행
```

---

## 위험 요소

| 위험 | 대응 |
|------|------|
| `TitleDateTimeButton` — dateAndTime 모드 미확인 | `CupertinoDatePickerMode.dateAndTime` 전달, content 포맷 검증 필요 |
| 점포 목록 — 실제 데이터 없음 | mock StoreSummary 리스트로 시작, TODO 주석 |
| 안내문 화면 미구현 | `TitleNavigationButton.onPressed: () {}` + TODO 주석 |
| `n번째` 산출 로직 미정 | placeholder `1` 하드코딩 → TODO 주석 |
| 음수 입력 포맷터 — 키보드 '-' 입력 | iOS number keyboard에는 '-' 키 없음 → `TextInputType.numberWithOptions(signed: true)` 사용 |
