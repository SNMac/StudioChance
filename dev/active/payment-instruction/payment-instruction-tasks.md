# 입금 안내문 — 태스크 체크리스트

Last Updated: 2026-05-20

## Phase 1: 패키지 추가

- [x] **1-1** `pubspec.yaml`에 `share_plus: ^13.1.0` 추가
- [x] **1-2** `flutter pub get` 실행

## Phase 2: Store 필드 추가 (Domain + Data)

- [x] **2-1** `lib/domain/entities/store.dart` — 5개 필드 추가
  - `bankName: String?`
  - `bankAccountNumber: String?`
  - `bankAccountHolder: String?`
  - `paymentDeadlineMinutes: int?` (분 단위 저장, 초기 설계 `paymentDeadlineHours`에서 변경)
  - `confirmationNotes: String?`

- [x] **2-2** `lib/data/models/store_model.dart` — 5개 필드 추가, `toEditableJson` / `fromEntity` / `toEntity` 업데이트
  - Firestore JSON key: `paymentDeadlineMinutes` (분 단위)

- [x] **2-3** 코드 생성 완료, `dart analyze` 오류 없음

## Phase 3: Store 상세 조회 Provider

- [x] **3-1** `lib/presentation/providers/store_detail_provider.dart` 생성
- [x] **3-2** `store_detail_provider.g.dart` 생성 확인

## Phase 4: 입금 안내문 화면

- [x] **4-1** `lib/presentation/home/screens/payment_instruction_screen.dart` 생성
  - `reservation: Reservation?` (nullable — null이면 미리보기 모드)
  - `previewStoreToEdit: Store?` — 미리보기 시 폼 컨트롤러 선택용
  - 미리보기 모드: `storeCreationControllerProvider` 또는 `storeUpdateControllerProvider`에서 폼 상태를 `ref.watch`
  - `_buildPreviewText(StoreFormState)` — 입력값 있으면 실제 값, 없으면 `{은행}` 등 placeholder
  - `_formatDuration(int minutes)` — 분→표시 문자열 (예: 90 → "1시간 30분")
  - 실제 예약 모드: 기존 동일 (Store 로딩 + 텍스트 생성)
  - Stack 레이아웃: `Positioned.fill` 스크롤 + `Positioned(bottom)` 버튼 고정
  - 버튼: `GroupedFormContainer` + `TextActionButton` × 2 (복사하기 / 공유하기)

## Phase 5: 라우팅 연결 (입금 안내문 화면)

- [x] **5-1** `lib/router/router_path.dart` — `paymentInstruction`, `storePaymentInfo` 추가
- [x] **5-2** `lib/router/app_router.dart`
  - `home` 하위: `paymentInstruction` (`Reservation?` extra)
  - `storeCreation/payment-info` 하위: `paymentInstruction` (`Store?` extra → `previewStoreToEdit`)
- [x] **5-3** `reservation_detail_modal.dart` — `context.push('/home/payment-instruction', extra: reservation)` 연결

## Phase 6: 입금 정보 입력 폼 (StoreFormScreen 연동)

- [x] **6-1** `StoreFormState`에 입금 정보 필드 추가
  - `bankName: String` (기본 `''`)
  - `bankAccountNumber: String` (기본 `''`)
  - `bankAccountHolder: String` (기본 `''`)
  - `paymentDeadlineMinutes: int?` (기본 `null`)

- [x] **6-2** `StoreFormControllerable` + `StoreFormMixin` — setter 4개 추가
  - `setBankName`, `setBankAccountNumber`, `setBankAccountHolder`, `setPaymentDeadlineMinutes`

- [x] **6-3** `StoreCreationController.getFormData()` — 신규 필드 포함
- [x] **6-4** `StoreUpdateController.build()` — 기존 store 값으로 초기화
- [x] **6-5** `StoreUpdateController.getFormData()` — 신규 필드 포함
- [x] **6-6** `TitleTextField` — `returnButtonType: TextInputAction?` 파라미터 추가

- [x] **6-7** `lib/presentation/commons/store_input/screens/payment_info_input_screen.dart` 생성
  - 레이아웃: `TitleTextField` × 3 (은행, 계좌번호, 예금주) + 인라인 duration picker (입금 마감 기한)
  - Duration picker: `CupertinoPicker`, 15분 단위, 15분 ~ 3시간 (12개 선택지)
  - picker 표시 형식: 60분 미만 `"45분"`, 60분 이상 `"1시간"` / `"1시간 30분"`
  - caption "예약 등록 시간 기준" → `GroupedFormContainer.footer`
  - "입금 안내문" `TextActionButton` → 폼 값 임시 저장 후 미리보기 화면 push
  - 라우트: `SCRoute.storePaymentInfo` (`store-creation/payment-info`)

- [x] **6-8** `StoreFormScreen` — "입금 정보" `TitleNavigationButton` 추가 (주소 ↔ 메모 사이)

## Phase 7: 요금 필드 포맷 개선

- [x] **7-1** `dart analyze` 오류 없음
- [x] **7-2** 앱 실행 → 예약 상세 모달 → '입금 안내문' 탭 → 화면 진입 확인
- [x] **7-3** 안내문 텍스트 플레이스홀더 치환 확인 (실제 예약 모드)
- [x] **7-4** Store 계좌 정보 null 시 해당 항목 빈 문자열 표시 확인
- [x] **7-5** 복사하기 → 클립보드 + SnackBar 확인
- [x] **7-6** 공유하기 → 시스템 공유 시트 표시 확인
- [x] **7-7** 뒤로가기 → 예약 상세 모달로 복귀 확인
- [ ] **7-8** 점포 생성 폼 → 입금 정보 → 값 입력 → 입금 안내문 미리보기에 실제 값 반영 확인
- [ ] **7-9** 점포 수정 모드 → 기존 입금 정보 초기값 로드 확인
- [ ] **7-10** 입금 마감 기한 picker → Firestore에 분 단위 저장 확인

## Phase 8: 요금 필드 포커스 기반 포맷

- [x] **8-1** `TimeSlotInputForm` — '요금' 필드 포커스 기반 포맷
  - 포커스 진입: 쉼표·'원' 제거 → 순수 숫자
  - 포커스 해제: `formattedPrice` 적용 → "7,000원" 형식
  - `import 'package:flutter/services.dart';` 누락 버그 수정
- [x] **8-2** `HeadcountInputForm` — '추가 인원 요금' 필드 동일 포맷 적용
  - `_extraPriceFocusNode` 추가, `_onExtraFocusChanged()` 구현
  - `_notifyParent()`에서 쉼표·'원' 제거 후 파싱
  - placeholder `'예: 2,000'`으로 통일
