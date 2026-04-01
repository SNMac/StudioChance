# 예약 확인 모달 — 컨텍스트 및 참조

Last Updated: 2026-04-01 (Phase 1~8 완료 → **설계 변경: 인라인 편집 모드 전환 방식으로 재구현 필요**)

---

## ⚠️ 설계 변경 (최우선 반영 필요)

### 기존 설계 (폐기)
- `ReservationDetailModal` (읽기 전용) → '편집' 버튼 → `showReservationEditModal` 호출 → **새 모달 열림**

### 새로운 설계
- **단일 모달**에서 읽기 전용 ↔ 편집 모드를 **인라인으로 전환**
- '편집' 버튼 → 같은 모달에서 필드가 편집 가능하게 변환
- '완료' 버튼 → 저장 후 읽기 전용 모드로 복귀 (모달 닫힘 아님)
- '취소' 버튼 → 모달 닫힘 (편집 중 취소 시 변경 내용 폐기)

---

## 현재 구현 상태

`reservation_detail_modal.dart` 는 **읽기 전용 전용 위젯**으로 구현되어 있음.
`ReservationDetailModal extends StatelessWidget` — 인라인 편집 불가.

이 파일을 **전면 재작성**해야 함.

---

## 재구현 방향

### 클래스 변경
```
ReservationDetailModal extends StatelessWidget
→ ReservationDetailModal extends ConsumerStatefulWidget
```

### 추가 상태
```dart
bool _isEditing = false;

// 편집 모드에서 사용하는 상태 (ReservationEditModal과 동일)
late StoreSummary _storeSummary;
late ReservationStatus _status;
late bool _isAllDay;
late DateTime _startTime;
late DateTime _endTime;
late String _platform;
late String _paymentMethod;
bool _isStartPickerOpen = false;
bool _isEndPickerOpen = false;

late final TextEditingController _nameController;
late final TextEditingController _headCountController;
late final TextEditingController _phoneController;
late final TextEditingController _memoController;
late final TextEditingController _priceController;
late final TextEditingController _adjustmentController;
```

### AppBar 전환
```dart
// 읽기 전용 모드
ModalAppBar(
  title: '예약 정보',
  leading: AppBarActionButton(label: '취소', onPressed: () => Navigator.pop(context)),
  actions: [AppBarActionButton(label: '편집', onPressed: _enterEditMode)],
)

// 편집 모드
ModalAppBar(
  title: '예약 수정',
  leading: AppBarActionButton(label: '취소', onPressed: _cancelEdit),
  actions: [AppBarActionButton(label: '완료', onPressed: _isValid ? _onComplete : null)],
)
```

### 취소 동작 분기
```dart
void _cancelEdit() {
  // 편집 중: 변경 내용 폐기 + 읽기 전용 복귀
  setState(() {
    _isEditing = false;
    _resetFields(); // widget.reservation 값으로 재초기화
    _isStartPickerOpen = false;
    _isEndPickerOpen = false;
  });
}
```

### 완료 동작
```dart
void _onComplete() {
  final updated = widget.reservation.copyWith(...); // 편집 상태 → Reservation
  widget.onSaved(updated);
  setState(() => _isEditing = false); // 모달 닫지 않고 읽기 전용으로 복귀
}
```

### 섹션별 빌드 전략
```dart
// 읽기 전용: TitleTextLabel, TitleSwitchButton(onChanged: null), _ReadOnlyMemo
// 편집: TitleTextField, TitlePopupButton, TitleSwitchButton(onChanged: ...), MemoTextField, TitleDateTimeButton
Widget _buildSection2() {
  if (_isEditing) return _buildSection2Edit();
  return _buildSection2ReadOnly();
}
```

---

## ReservationEditModal 처리

`reservation_edit_modal.dart`는 더 이상 `ReservationDetailModal`에서 호출하지 않음.
→ `showReservationEditModal` 호출처가 없어짐 (기존 detail modal의 `_onEdit` 제거)
→ `reservation_edit_modal.dart` 파일 **삭제 검토** (또는 향후 독립 진입점으로 유지)

현재로서는 파일을 남겨두되, `dev/active/reservation-edit-modal`을 스코프 아웃으로 닫을 수 있음.

---

## 관련 파일 경로

| 파일 | 역할 |
|------|------|
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | **재작성 대상** |
| `lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart` | 편집 로직 참조 (이후 삭제 검토) |
| `lib/constants/data_constants.dart` | `reservationPlatforms`, `paymentMethods` 상수 |
| `lib/domain/entities/reservation.dart` | `Reservation` freezed 엔티티 |
| `lib/presentation/commons/widgets/input_form/` | 폼 컴포넌트 모음 |

---

## 도메인 엔티티 (Reservation)

```dart
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required StoreSummary storeSummary,
    required StoreMemberInfo writer,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required String memo,
    required bool isAllDay,
    required DateTime startTime,
    required DateTime endTime,
    required String platform,
    required String paymentMethod,
    required int calculatedPrice,
    required int priceAdjustment,
    required int totalPrice,
  }) = _Reservation;
}
```

---

## onSaved 파라미터 추가

`showReservationDetailModal`에 `onSaved` 콜백 추가 필요:
```dart
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation, {
  List<StoreSummary>? availableStores,   // null이면 [reservation.storeSummary] 사용
  required void Function(Reservation) onSaved,
})
```

호출처인 `time_grid.dart`도 함께 수정 필요.

---

## 미결/후속 작업

| 항목 | 내용 |
|------|------|
| `n번째` 계산 | 실제 데이터 연결 전까지 `1` 하드코딩 유지 |
| 입금/확정 안내문 | `TitleNavigationButton.onPressed` TODO 유지 |
| `onSaved` 실제 연결 | 예약 저장 Use Case + Repository 구현 후 연결 |
| `availableStores` 공급 | Home Provider에서 사용자 가입 점포 목록 fetch 후 전달 |
| 숫자 콤마 포맷 | `calculatedPrice.toString()` → `"50,000"` style (스코프 아웃) |
| `_formatDateTime` 공통화 | 현재 편집/확인 모달 각각 private 선언 (스코프 아웃) |
| `ReservationEditModal` 삭제 | 재구현 후 더 이상 사용하지 않으면 삭제 |
