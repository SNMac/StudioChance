# 예약 확인 모달 구현 계획

Last Updated: 2026-04-22 (iOS/Android 스크롤 보존 모두 해결 완료 — 17-E Option A)

---

## 개요

`reservation_detail_modal.dart`를 **인라인 모드 전환** 방식으로 재구현한다.
별도 편집 모달을 열지 않고, 하나의 모달 내에서 읽기 전용 ↔ 편집 모드를 전환한다.

---

## 설계 원칙

| 항목 | 내용 |
|------|------|
| 모달 개수 | **1개** — 읽기 전용 / 편집 모드 통합 |
| 클래스 타입 | `ConsumerStatefulWidget` (편집 상태 관리 필요) |
| 편집 진입 | '편집' 버튼 → `setState(() => _isEditing = true)` |
| 편집 취소 | '취소' 버튼 → `_resetFields()` + `setState(() => _isEditing = false)` |
| 편집 완료 | '완료' 버튼 → `onSaved(updated)` + `setState(() => _isEditing = false)` |
| 모달 닫기 | 읽기 전용 상태에서 '취소' 버튼만 `Navigator.pop` |

---

## AppBar 전환

```
[읽기 전용]  취소  │  예약 정보  │  편집
[편집 중]    취소  │  예약 수정  │  완료(유효시 활성)
```

---

## 섹션별 위젯 전환 전략

| 섹션 | 읽기 전용 | 편집 |
|------|----------|------|
| 1. 기본 정보 | `TitleTextLabel` x2 | `TitlePopupButton` x2 |
| 2. 예약자 정보 | `TitleTextLabel` x3 + `_ReadOnlyMemo` | `TitleTextField` x3 + `MemoTextField` |
| 3. 일시 정보 | `TitleSwitchButton(null)` + `TitleTextLabel` x2 | `TitleSwitchButton` + `TitleDateTimeButton` x2 |
| 4. 결제 정보 | `TitleTextLabel` x4 (footer 없음) | `TitlePopupButton` x2 + `TitleTextField` x2 (footer 있음) |
| 5. 안내문 | `TitleNavigationButton` x2 | 동일 |

---

## 상태 필드

읽기 전용 모드에서도 편집 상태를 유지해야 하므로 (`_isEditing` 토글 시 재초기화 없이 유지하거나,
취소 시 `_resetFields()`로 재초기화), 모든 편집 상태를 항상 보유한다.

```dart
bool _isEditing = false;

// 편집 상태 (initState에서 widget.reservation으로 초기화)
late StoreSummary _storeSummary;
late ReservationStatus _status;
late bool _isAllDay;
late DateTime _startTime, _endTime;
late String _platform, _paymentMethod;
bool _isStartPickerOpen = false;
bool _isEndPickerOpen = false;

// 텍스트 컨트롤러
late final TextEditingController _nameController;
late final TextEditingController _headCountController;
late final TextEditingController _phoneController;
late final TextEditingController _memoController;
late final TextEditingController _priceController;
late final TextEditingController _adjustmentController;
```

---

## 취소 동작 상세

```dart
// 읽기 전용 중 취소 (모달 닫기)
if (!_isEditing) {
  Navigator.pop(context);
  return;
}

// 편집 중 취소 (변경 내용 폐기 + 읽기 전용 복귀)
_resetFields();
setState(() {
  _isEditing = false;
  _isStartPickerOpen = false;
  _isEndPickerOpen = false;
});
```

---

## showReservationDetailModal 시그니처 변경

```dart
// 기존
Future<void> showReservationDetailModal(BuildContext context, Reservation reservation)

// 변경 후
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation, {
  List<StoreSummary>? availableStores,
  required void Function(Reservation) onSaved,
})
```

---

## ReservationEditModal 폐기

`reservation_edit_modal.dart`는 더 이상 `showReservationDetailModal`에서 호출하지 않음.
→ 독립 진입점으로 사용하지 않으면 파일 삭제.

---

## 신규/수정 파일

```
lib/presentation/home/widgets/three_day_calendar/
├── reservation_detail_modal.dart   # 재작성 (StatelessWidget → ConsumerStatefulWidget)
└── reservation_edit_modal.dart     # 삭제 예정 (더 이상 사용 안 함)
```

---

## 위험 요소

| 위험 | 대응 |
|------|------|
| `_resetFields()` 누락 시 취소 후 이전 편집값 잔류 | `_cancelEdit()`에서 반드시 호출 |
| TextEditingController 재설정 방식 | `controller.text = ...` 으로 재설정 (new 할당 불필요) |
| `_isValid` 편집 모드 진입/복귀 시 초기화 | `_resetFields()` 후 `setState` → build에서 재평가 |
| `showReservationDetailModal` 호출처 누락 | `time_grid.dart` 등 호출처에 `onSaved` 추가 필요 |

---

## 진행 상황 요약 (2026-04-22 기준)

- **Phase 9~16**: 완료. 인라인 편집 모드 전환, Reservation Data Layer, 단위 테스트(26개) 모두 완료.
- **Phase 17 (iOS)**: ✅ 해결. Stack + Offstage + 독립 ScrollController 방식 (17-C).
- **Phase 17 (Android)**: ✅ 해결. `DraggableScrollableSheet` 제거 + 고정 90% 높이 `showModalBottomSheet` (17-E Option A).
  - 플랫폼 공통 Stack+Offstage 구조로 통일됨. snap 기능은 제거됨.
