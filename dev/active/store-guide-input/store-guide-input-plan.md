# 안내사항 입력 화면 — 구현 계획

Last Updated: 2026-05-19

## 개요

점포 생성/수정 플로우에서 **점포 안내·주의사항(confirmationNotes)** 을 입력할 수 있는 화면을 추가한다.
입금 정보 입력 화면(`PaymentInfoInputScreen`)과 동일한 패턴으로, 텍스트 입력 영역과 확정 안내문 프리뷰 버튼을 포함한다.

## 배경

- `Store.confirmationNotes` 필드는 `payment-instruction` 태스크에서 도메인 엔티티에 추가됨
- 기존 점포 생성 폼(`StoreFormScreen`)에는 이 값을 편집할 UI가 없었음
- 확정 안내문(ConfirmationNoticeScreen)은 예약 확정 후 발송용이지만, 점포 생성 중 미리보기도 필요

## 요구사항

1. 점포 생성·수정 폼에 "안내사항" 내비게이션 버튼 추가 (입금 정보 아래)
2. "안내사항" 전용 입력 화면: 1000자 제한 텍스트 영역 + 확정 안내문 프리뷰 버튼
3. 확정 안내문 화면이 프리뷰 모드를 지원 (폼 상태 기반, 실제 예약 없이)
4. 입력값이 `StoreFormState.confirmationNotes`에 저장되고, submit 시 `Store.confirmationNotes`에 반영

## 아키텍처 결정

### confirmationNotes 필드 위치
`StoreFormState`에 `@Default('') String confirmationNotes` 추가.
`submit()` 시 빈 문자열이면 `null`로 변환해 `Store`에 저장 (입금 정보 필드와 동일한 패턴).

### 확정 안내문 프리뷰 진입 경로
- **점포 생성/수정 플로우**: `storeGuide` 라우트 하위의 `confirmationNotice` 서브 라우트
  - extra: `Store?` (생성=null, 수정=Store 인스턴스)
- **예약 상세 모달 플로우**: 기존 home 하위 `confirmationNotice` 라우트 유지
  - extra: `Reservation?` (non-null 실사용)

### ConfirmationNoticeScreen 파라미터
```dart
const ConfirmationNoticeScreen({
  this.reservation,       // null → 프리뷰 모드
  this.previewStoreToEdit, // null = 생성 모드, 값 = 수정 모드
});
```
`reservation == null`이면 `storeCreationControllerProvider` 또는
`storeUpdateControllerProvider`를 읽어 폼 상태 기반 프리뷰 텍스트 빌드.

## 구현 범위

| 레이어 | 파일 | 변경 종류 |
|--------|------|----------|
| Constants | `constants/data_constants.dart` | `maxConfirmationNotesCharCount = 1000` 추가 |
| Domain Form State | `store_input/controllers/states/store_form_state.dart` | `confirmationNotes` 필드 추가 |
| Domain Form Contract | `store_input/controllers/store_form_controllerable.dart` | `setConfirmationNotes` 인터페이스·믹스인 추가 |
| Presentation | `store_input/controllers/store_creation_controller.dart` | `getFormData()`에 `confirmationNotes` 반영 |
| Presentation | `store_input/controllers/store_update_controller.dart` | `build()` 초기값 + `getFormData()` 반영 |
| Router | `router/router_path.dart` | `storeGuide` 케이스 추가 |
| Router | `router/app_router.dart` | `storeGuide` 라우트 + `confirmationNotice` 서브 라우트 등록 |
| UI | `store_input/screens/store_form_screen.dart` | "안내사항" `TitleNavigationButton` 추가 |
| UI (신규) | `store_input/screens/store_guide_input_screen.dart` | 안내사항 입력 화면 신규 생성 |
| UI | `home/screens/confirmation_notice_screen.dart` | 프리뷰 모드 추가 |
