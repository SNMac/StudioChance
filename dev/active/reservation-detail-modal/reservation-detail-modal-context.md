# 예약 확인 모달 — 컨텍스트 및 참조

Last Updated: 2026-04-20 (Reservation Data Layer 테스트 코드 추가)

---

## ✅ 구현 완료 (Phase 9~14)

### 설계
- **단일 모달**에서 읽기 전용 ↔ 편집 모드를 **인라인으로 전환**
- '편집' 버튼 → 같은 모달에서 필드가 편집 가능하게 변환
- '완료' 버튼 → 저장 후 읽기 전용 모드로 복귀 (모달 닫힘 아님)
- '취소' 버튼 → 읽기 전용 중이면 모달 닫기, 편집 중이면 변경 내용 폐기 + 읽기 전용 복귀

### 현재 구현 상태

`ReservationDetailModal extends ConsumerStatefulWidget` — 인라인 편집 모드 전환 완료.
`dart analyze` 통과 (firebase_options.dart 제외).

### 이번 세션 주요 변경
- `_ReadOnlyMemo` 최소 높이: `inputFormComponentHeight(48)` → `memoMinHeight(96)`, bottom padding 12 → 32 (MemoTextField 편집 모드와 높이 일치)
- `ui_constants.dart`에 `memoMinHeight = 96.0` 상수 추가
- **`reservationPlatforms`, `paymentMethods` const List → enum 전환** (2026-04-19)
  - `lib/domain/enums/reservation_platform.dart` (ReservationPlatform: naver/spaceCloud/yanolja/other)
  - `lib/domain/enums/payment_method.dart` (PaymentMethod: onSite/bankTransfer/other)
  - `Reservation.platform: String` → `ReservationPlatform`, `paymentMethod: String` → `PaymentMethod`
  - `ReservationModel` 동일하게 변경
  - 모달 상태 필드: `late String _platform/_paymentMethod` → `late ReservationPlatform/PaymentMethod`
  - `TitlePopupButton<String>` → `TitlePopupButton<ReservationPlatform/PaymentMethod>`, `itemLabelBuilder: (p) => p.displayName`
  - 읽기 전용 표시: `reservation.platform` → `reservation.platform.displayName`
  - `data_constants.dart`에서 두 const List 제거 (import는 `maxMemoCharCount` 때문에 유지)
- **Reservation Data Layer 신규 구현** (2026-04-19)
  - `lib/common/exceptions/reservation_exceptions.dart`
  - `lib/data/data_sources/reservation_data_source.dart` (Firestore 서브컬렉션: `stores/{storeId}/reservations/`)
  - `lib/domain/repository_interfaces/reservation_repository.dart`
  - `lib/data/repositories/reservation_repository_impl.dart`
  - `lib/domain/use_cases/reservation_use_case.dart`
- **Reservation 테스트 코드 추가** (2026-04-20)
  - `test/helpers/fake_data.dart` — 예약 관련 fake 데이터 추가 (fakeStoreSummary, fakeWriterMemberInfo, fakeReservation, fakeReservationModel, fakeStoreModel, fakeUserModel)
  - `test/data/repositories/reservation_repository_test.dart` — Repository 단위 테스트 12개 (전체 통과)
  - `test/domain/use_cases/reservation_use_case_test.dart` — UseCase 단위 테스트 14개 (전체 통과)
  - `flutter test` 26개 전체 통과 확인 후 커밋 완료

---

## 테스트 구조 (Reservation Data Layer)

### fake_data.dart 추가 항목
```dart
// 도메인 엔티티 fakes
final fakeStoreSummary = StoreSummary(id: 'store-123', name: '테스트 점포', color: StoreColor.blue);
final fakeWriterMemberInfo = StoreMemberInfo(user: fakeUser, role: UserRole.admin);
final fakeReservation = Reservation(id: 'res-001', storeSummary: fakeStoreSummary, ...);

// 데이터 모델 fakes (Repository 테스트용)
final fakeReservationModel = ReservationModel(id: 'res-001', storeId: 'store-123', writerId: 'user-123', ...);
final fakeStoreModel = StoreModel(..., memberById: {'user-123': StoreMemberInfoModel(role: UserRole.admin)});
final fakeUserModel = UserModel(..., storeById: {'store-123': UserStoreInfoModel(color: StoreColor.blue, ...)});
```

### reservation_repository_test.dart — 12개 테스트
| group | 테스트 내용 |
|-------|------------|
| createReservation | DataSource 반환 모델로 엔티티 변환 right 반환 / DataSource 실패 시 left |
| getReservationsByDateRange | 빈 목록 → 추가 조회 없음 / StoreSummary color, writer.role 검증 / StoreDataSource null → left / DS 실패 → left |
| updateReservation | 올바른 storeId/reservationId로 DS 호출 / DS 실패 → left |
| deleteReservation | 올바른 파라미터로 DS 호출 / DS 실패 → left |
| updateReservationStatus | status.name 포함 데이터로 DS 호출 / DS 실패 → left |

### reservation_use_case_test.dart — 14개 테스트
| group | 테스트 내용 |
|-------|------------|
| createReservation | writer.user를 현재 로그인 유저로 교체 / writer.role 원본 유지 / 유저 조회 실패 → left + repo 미호출 / 현재 유저 null → left / repo 실패 → left |
| getReservationsByDateRange | currentUid 자동 획득 후 repo 호출 / 유저 조회 실패 → left / repo 실패 → left |
| updateReservation | repo 위임 / repo 실패 → left |
| deleteReservation | 올바른 파라미터 repo 호출 / repo 실패 → left |
| updateReservationStatus | 올바른 파라미터 repo 호출 / repo 실패 → left |

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
// 읽기 전용 모드: leading='닫기'(일반굵기), actions=['편집']
ModalAppBar(
  title: '예약 정보',
  leading: AppBarActionButton(label: '닫기', isRegularWeight: true, onPressed: _onCancelPressed),
  actions: [AppBarActionButton(label: '편집', onPressed: () => setState(() => _isEditing = true))],
)

// 편집 모드: leading='취소'(일반굵기), actions=['완료'(유효할 때만 활성)]
ModalAppBar(
  title: '예약 수정',
  leading: AppBarActionButton(label: '취소', isRegularWeight: true, onPressed: _onCancelPressed),
  actions: [AppBarActionButton(label: '완료', onPressed: _isValid ? _onComplete : null)],
)
```
> **결정**: leading 버튼은 모드 무관하게 항상 `isRegularWeight: true`.
> 읽기 전용='닫기'(모달 닫기), 편집='취소'(변경 폐기 + 읽기 전용 복귀).
> 실제 코드에서 `_onCancelPressed()`가 `_isEditing` 여부로 분기.
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
→ `showReservationEditModal` 호출처 없음 (기존 detail modal의 `_onEdit` 제거됨)
→ **2026-04-19 파일 삭제 완료** — 독립 진입점 불필요, 편집 로직은 `ReservationDetailModal` 내부로 통합됨.

---

## 관련 파일 경로

| 파일 | 역할 |
|------|------|
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | **재작성 대상** |
| `lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart` | 편집 로직 참조 (이후 삭제 검토) |
| `lib/domain/enums/reservation_platform.dart` | `ReservationPlatform` enum (naver/spaceCloud/yanolja/other) |
| `lib/domain/enums/payment_method.dart` | `PaymentMethod` enum (onSite/bankTransfer/other) |
| `lib/constants/data_constants.dart` | `maxMemoCharCount` 등 공통 상수 (플랫폼/결제 목록은 enum으로 이전) |
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
    required ReservationPlatform platform,   // ← String에서 변경
    required PaymentMethod paymentMethod,    // ← String에서 변경
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
| ~~`ReservationEditModal` 삭제~~ | 2026-04-19 삭제 완료 ✅ |
