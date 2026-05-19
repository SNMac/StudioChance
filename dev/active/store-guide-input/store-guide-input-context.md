# 안내사항 입력 화면 — 핵심 파일 및 의존성

Last Updated: 2026-05-19

## 수정 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `lib/constants/data_constants.dart` | `maxConfirmationNotesCharCount = 1000` 추가 |
| `lib/presentation/commons/store_input/controllers/states/store_form_state.dart` | `@Default('') String confirmationNotes` 필드 추가 |
| `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` | `setConfirmationNotes(String)` 인터페이스·믹스인 추가 |
| `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` | `getFormData()` 에 `confirmationNotes` 포함 |
| `lib/presentation/commons/store_input/controllers/store_update_controller.dart` | `build()` 초기화 + `getFormData()` 에 `confirmationNotes` 포함 |
| `lib/router/router_path.dart` | `storeGuide` 케이스 (`'guide'`) 추가 |
| `lib/router/app_router.dart` | `storeGuide` GoRoute + 하위 `confirmationNotice` 프리뷰 라우트 등록 |
| `lib/presentation/commons/store_input/screens/store_form_screen.dart` | "안내사항" `TitleNavigationButton` 추가 (입금 정보 ↔ 메모 사이) |
| `lib/presentation/home/screens/confirmation_notice_screen.dart` | `reservation` nullable화, `previewStoreToEdit` 파라미터 추가, 프리뷰 로직 추가 |

## 신규 생성 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/commons/store_input/screens/store_guide_input_screen.dart` | 안내사항 입력 화면 |

## 라우트 구조

```
role/
  admin-store-registration/
    store-creation/          (StoreFormScreen)
      ...
      guide/                 (StoreGuideInputScreen)  ← 신규
        confirmation-notice/ (ConfirmationNoticeScreen — 프리뷰 모드)  ← 신규
      ...

home/
  payment-instruction/       (PaymentInstructionScreen)
  confirmation-notice/       (ConfirmationNoticeScreen — 실 예약 모드)  ← 기존 유지
```

## ConfirmationNoticeScreen 동작 분기

```dart
// 프리뷰 모드 (store-guide 플로우)
ConfirmationNoticeScreen(previewStoreToEdit: Store?)
// → reservation == null
// → storeUpdateControllerProvider(previewStoreToEdit!) 또는 storeCreationControllerProvider 읽음
// → _buildPreviewText(formState) 호출

// 실 예약 모드 (home 플로우)
ConfirmationNoticeScreen(reservation: Reservation?)
// → reservation != null
// → storeDetailProvider(reservation!.storeSummary.id) 로드
// → _buildText(store) 호출 (기존 로직 동일)
```

## 프리뷰 텍스트 구조 (confirmationNotes 없을 때)

```
[{점포명} 예약 확정 안내]
안녕하세요, {점포명}입니다.

입금 확인이 완료되어 예약이 확정되었습니다. 예약 정보를 아래에 다시 한 번 안내드립니다.

• 예약자명: {예약자명}
• 예약자 전화번호: {예약자 전화번호}
• 예약 시간: {yyyy}년 {mm}월 {dd}일 ({요일}) {hh}시 ~ {hh}시 ({n}시간)
• 예약 인원: {예약 인원}인
• 이용 장소: {폼 상태의 실제 주소 또는 {이용 장소}}

이용해 주셔서 감사합니다! 좋은 시간 보내세요. 🙇‍♂️
```

confirmationNotes가 있으면 이용 장소 다음에 `📌 안내·주의사항\n{내용}\n` 섹션 삽입.

## 재사용 패턴

`StoreGuideInputScreen`은 `PaymentInfoInputScreen`과 동일한 패턴 사용:
- `didChangeDependencies` + `_isInitialized` 플래그로 `GoRouterState.extra` 접근
- `완료` 버튼 → `notifier.setConfirmationNotes(text)` 후 `context.pop()`
- `확정 안내문` 버튼 → `notifier.setConfirmationNotes(text)` 후 `SCRoute.confirmationNotice.pushChild(context, extra: storeToEdit)`

## 관련 문서

- `dev/active/confirmation-notice/` — 확정 안내문 실 예약 모드 화면 컨텍스트
- `dev/active/payment-instruction/` — 입금 안내문 (동일 UI 구조 참고)
