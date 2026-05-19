# 안내사항 입력 화면 — 태스크 체크리스트

Last Updated: 2026-05-19

## Phase 1: 상태·컨트롤러

- [x] **1-1** `data_constants.dart` — `maxConfirmationNotesCharCount = 1000` 추가
- [x] **1-2** `StoreFormState` — `@Default('') String confirmationNotes` 필드 추가
- [x] **1-3** `StoreFormControllerable` — `setConfirmationNotes(String)` 인터페이스·믹스인 추가
- [x] **1-4** `StoreCreationController.getFormData()` — `confirmationNotes` 반영
- [x] **1-5** `StoreUpdateController.build()` — `confirmationNotes` 초기값 로드
- [x] **1-6** `StoreUpdateController.getFormData()` — `confirmationNotes` 반영
- [x] **1-7** `dart run build_runner build` 실행 — freezed 재생성 확인

## Phase 2: 라우팅

- [x] **2-1** `router_path.dart` — `storeGuide` 케이스 추가 (`'guide'`)
- [x] **2-2** `app_router.dart` — `storeGuide` GoRoute 등록 (storeCreation 하위)
- [x] **2-3** `app_router.dart` — `storeGuide` 하위에 `confirmationNotice` 프리뷰 서브 라우트 등록

## Phase 3: UI 구현

- [x] **3-1** `store_form_screen.dart` — "안내사항" `TitleNavigationButton` 추가
- [x] **3-2** `store_guide_input_screen.dart` 신규 생성
  - `MemoTextField(placeholder: '점포 안내·주의사항', maxLength: 1000)`
  - `확정 안내문` `TextActionButton` → `SCRoute.confirmationNotice.pushChild`
  - `완료` `AppBarActionButton` → `notifier.setConfirmationNotes(text)` + `context.pop()`
- [x] **3-3** `confirmation_notice_screen.dart` — 프리뷰 모드 추가
  - `reservation` nullable화
  - `previewStoreToEdit` 파라미터 추가
  - `_buildPreviewText(StoreFormState)` 메서드 추가
  - `_buildContent` → `_buildBody` 공통 메서드 추출

## 검증

- [x] **4-1** `dart analyze` 오류 없음
- [ ] **4-2** 점포 생성 폼 → "안내사항" 탭 → 입력 화면 진입 확인
- [ ] **4-3** 입력 후 "완료" → 폼으로 복귀, 값 보존 확인
- [ ] **4-4** "확정 안내문" 탭 → 프리뷰 화면 진입 확인
- [ ] **4-5** 주소 입력 후 프리뷰 → 이용 장소에 실제 주소 반영 확인
- [ ] **4-6** `confirmationNotes` 입력 후 프리뷰 → 📌 섹션 표시 확인
- [ ] **4-7** `confirmationNotes` 없을 때 프리뷰 → 📌 섹션 생략 확인
- [ ] **4-8** 프리뷰 복사하기 → 클립보드 + SnackBar 확인
- [ ] **4-9** 프리뷰 공유하기 → 시스템 공유 시트 확인
- [ ] **4-10** 점포 생성 submit → `Store.confirmationNotes` Firestore 저장 확인
- [ ] **4-11** 점포 수정 모드 → 기존 `confirmationNotes` 초기값 로드 확인
- [ ] **4-12** 예약 상세 모달 → 확정 안내문(기존 home 플로우) 정상 동작 확인 (회귀 테스트)
