# 입금 안내문 — 핵심 파일 및 의존성

Last Updated: 2026-05-20

## 수정된 파일

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `share_plus` 추가 |
| `lib/domain/entities/store.dart` | `bankName`, `bankAccountNumber`, `bankAccountHolder`, `paymentDeadlineMinutes`, `confirmationNotes` 추가 |
| `lib/data/models/store_model.dart` | 동일 5개 필드 추가, `toEditableJson`, `toEntity`, `fromEntity` 업데이트 |
| `lib/presentation/commons/store_input/controllers/states/store_form_state.dart` | `bankName`, `bankAccountNumber`, `bankAccountHolder`, `paymentDeadlineMinutes` 추가 |
| `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` | setter 4개 추가 (interface + mixin) |
| `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` | `getFormData()` — 입금 필드 포함 |
| `lib/presentation/commons/store_input/controllers/store_update_controller.dart` | `build()` 초기화 + `getFormData()` — 입금 필드 포함 |
| `lib/presentation/commons/store_input/screens/store_form_screen.dart` | "입금 정보" `TitleNavigationButton` 추가 |
| `lib/presentation/commons/widgets/input_form/title_text_field.dart` | `returnButtonType: TextInputAction?`, `focusNode: FocusNode?` 파라미터 추가 |
| `lib/router/router_path.dart` | `storePaymentInfo`, `paymentInstruction`, `confirmationNotice` 추가 |
| `lib/router/app_router.dart` | home 서브 라우트 + storeCreation/payment-info 하위 중첩 라우트 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:932` | `입금 안내문` onPressed 연결 |
| `lib/presentation/commons/store_input/widgets/time_slot_input_form.dart` | '요금' 필드 포커스 기반 포맷 (`_priceFocusNode`, `_onPriceFocusChanged`) + `services.dart` import 추가 |
| `lib/presentation/commons/store_input/widgets/headcount_input_form.dart` | '추가 인원 요금' 필드 포커스 기반 포맷 (`_extraPriceFocusNode`, `_onExtraFocusChanged`) |

## 신규 생성 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/providers/store_detail_provider.dart` | Store 상세 조회 family provider |
| `lib/presentation/home/screens/payment_instruction_screen.dart` | 입금 안내문 화면 (실제 예약 + 미리보기 모드) |
| `lib/presentation/commons/store_input/screens/payment_info_input_screen.dart` | 입금 정보 입력 화면 |

---

## Store 필드 상세

```dart
// domain/entities/store.dart
String? bankName;             // 점포 계좌 은행
String? bankAccountNumber;    // 점포 계좌번호
String? bankAccountHolder;    // 점포 계좌 예금주
int?    paymentDeadlineMinutes; // 입금 마감 시간 (분 단위, 15~180)
String? confirmationNotes;    // 확정 안내문 주의사항 (추후 확정 안내문 작업용)
```

> **주의**: 초기 설계에서 `paymentDeadlineHours`(시간 단위)였으나 **분 단위**(`paymentDeadlineMinutes`)로 변경됨.
> Firestore JSON key도 `paymentDeadlineMinutes`. 기존 저장 데이터 없어 마이그레이션 불필요.

---

## PaymentInstructionScreen — 동작 모드

```
reservation != null  →  실제 예약 모드
  - storeDetailProvider(reservation.storeSummary.id) 로딩
  - _buildText(Reservation, Store?) 로 실제 데이터 텍스트 생성
  - 복사하기 / 공유하기 버튼 활성

reservation == null  →  미리보기 모드 (StoreFormScreen에서 진입)
  - previewStoreToEdit != null → storeUpdateControllerProvider 읽기
  - previewStoreToEdit == null → storeCreationControllerProvider 읽기
  - _buildPreviewText(StoreFormState) 로 텍스트 생성
    - 입력된 bank 정보 있으면 실제 값 표시
    - 없으면 {은행}, {계좌번호}, {예금주} placeholder
  - 복사하기 / 공유하기 버튼 활성 (template 공유 가능)
```

---

## PaymentInfoInputScreen — 입금 마감 기한 Picker

```dart
// 선택지 (15분 단위, 총 12개)
const List<int> _deadlineOptions = [15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180];

// 표시 형식
String _formatDuration(int minutes) {
  if (minutes < 60) return '$minutes분';
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (remaining == 0) return '$hours시간';
  return '$hours시간 $remaining분';
}
```

- `CupertinoPicker` 인라인 펼침 (AnimatedContainer, 300ms)
- `TitleDateTimeButton` 동일 시각 패턴 (`tertiarySystemFill` 배경 버튼)
- picker 열릴 때 선택값 없으면 15분으로 자동 설정
- `FixedExtentScrollController(initialItem: index)` 로 기존 값 위치 복원

---

## "입금 안내문" 버튼 동작 (PaymentInfoInputScreen)

```dart
onPressed: () {
  // 1. 현재 입력값을 폼 컨트롤러에 임시 저장 (pop 없이)
  notifier.setBankName(_bankNameController.text);
  notifier.setBankAccountNumber(...);
  notifier.setBankAccountHolder(...);
  notifier.setPaymentDeadlineMinutes(_selectedMinutes);
  // 2. storeToEdit을 extra로 전달 → 미리보기 화면이 올바른 컨트롤러를 읽도록
  SCRoute.paymentInstruction.pushChild(context, extra: storeToEdit);
},
```

---

## 라우트 구조

```
/home
  └── /payment-instruction     →  PaymentInstructionScreen(reservation: Reservation?)

/onboarding/role/admin-store-registration/store-creation
  └── /color                   →  StoreColorSelectionScreen
  └── /address                 →  StoreAddressInputScreen
  └── /payment-info            →  PaymentInfoInputScreen
      └── /payment-instruction →  PaymentInstructionScreen(previewStoreToEdit: Store?)
  └── /price-days              →  PriceDaysInputScreen
  └── /price-time              →  PriceTimeInputScreen
```

---

## 안내문 텍스트 빌드 로직 (실제 예약 모드)

```dart
String _buildText(Reservation r, Store? store) { ... }
```

마감 시간 표시:
```dart
final deadlineLine = store?.paymentDeadlineMinutes != null
    ? '✔ 입금 마감 시간: 앱에 예약 등록한 시간 기준 ${_formatDuration(store!.paymentDeadlineMinutes!)} 이내\n'
    : '';
```

---

## 코드 생성 필요 파일

```bash
dart run build_runner build --delete-conflicting-outputs
```

재생성 대상:
- `store.freezed.dart`
- `store_model.freezed.dart`, `store_model.g.dart`
- `store_form_state.freezed.dart`
- `store_detail_provider.g.dart`

---

---

## 요금 필드 포커스 기반 포맷 패턴

요금 입력 필드에 적용된 UX 패턴:
- **포커스 진입**: 쉼표·'원' 제거 → 순수 숫자만 표시 (키보드 입력 편의)
- **포커스 해제**: `formattedPrice` 적용 → "7,000원" 형식으로 표시
- `inputFormatters: [FilteringTextInputFormatter.digitsOnly]` — 키보드 입력은 숫자만 허용
- 프로그래매틱 변경(focus 시)은 formatter를 우회하므로 "원" 제거 가능

구현 파일:
- `time_slot_input_form.dart` — `_priceFocusNode`, `_onPriceFocusChanged()`
- `headcount_input_form.dart` — `_extraPriceFocusNode`, `_onExtraFocusChanged()`
- 예약 상세 모달 추가 요금/할인 필드에도 동일 패턴 적용 예정

```dart
void _onFocusChanged() {
  final raw = _controller.text.replaceAll(',', '').replaceAll('원', '');
  if (_focusNode.hasFocus) {
    _controller.value = TextEditingValue(
      text: raw,
      selection: TextSelection.collapsed(offset: raw.length),
    );
  } else {
    final price = int.tryParse(raw);
    if (price != null && price >= 0) {
      final formatted = price.formattedPrice;
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}
```

---

## 관련 문서

- `dev/active/reservation-detail-modal/` — 예약 상세 모달 컨텍스트
- `dev/active/home-screen/` — 홈 화면 컨텍스트
