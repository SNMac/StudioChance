# 예약 등록 버튼 — 태스크 체크리스트

Last Updated: 2026-05-19 (Phase 6 추가 — 유효성 강화 + 요금 자동 계산 + ConsumerStatefulWidget 전환)

## Phase 1: Controller 확장 (S) ✅

- [x] **1-1** `HomeReservationActionsController`에 `createReservation(Reservation)` 추가
  - `Future<bool>` 반환 (성공 여부)
  - 성공 시 `ref.invalidate(homeReservationsProvider)` (family 전체 무효화)
  - 실패 시 `_logger.e(...)` 로그

## Phase 2: 예약 생성 모달 (L) ✅

- [x] **2-1** `reservation_create_modal.dart` 신규 작성
  - `StatefulWidget` (Riverpod 불필요 — onSaved 콜백으로 위임)
  - 풀스크린, Grabber 없음, 취소/저장 버튼
  - 섹션 1~4 (점포/상태, 예약자, 일시, 결제)
- [x] **2-2** `showReservationCreateModal()` 헬퍼 함수 작성
- [x] **2-3** `_isValid` 유효성 검사 구현

## Phase 3: HomeScreen FAB 추가 (S) ✅

- [x] **3-1** `storeInfos`, `selectedStartDate` 구독 추가
- [x] **3-2** `_AddReservationFab` 커스텀 위젯 작성
  - 44×44 원형, `context.systemBlue` 배경, `CupertinoIcons.plus` size 20, white
  - `BoxDecoration(shape: BoxShape.circle)` + `boxShadow`
  - `Scaffold.floatingActionButton` + `FloatingActionButtonLocation.endFloat`
- [x] **3-3** 역할 기반 가시성: `admin` 또는 `staff`만 표시
  - `canCreateReservation = storeInfos.any(role == admin || role == staff)`
  - 점포 선택 목록도 `admin`/`staff` 점포로 필터링

## Phase 4: 검증 ✅

- [x] **4-1** `dart analyze` — No issues found
- [x] **4-2** build_runner 불필요 (Controller 메서드 추가는 코드 생성 대상 아님)
- [x] **4-3** 시뮬레이터 확인 — FAB 미표시 원인: 점포 없는 계정 (의도된 동작)

## 커밋 정보

- 브랜치: `feat/#5-home`
- 커밋: `ec9d359` — feat: #5 - 예약 등록 버튼 및 생성 모달 추가

## ✅ Phase 5: 생성 모달 Grabber 여백 추가 (커밋 fbd3503)

- [x] `reservation_create_modal.dart` — `Opacity(opacity: 0.0, child: ModalGrabber())` 추가
  - grabber pill 시각은 숨기되 상단 레이아웃 여백 유지
  - detail modal의 `Opacity(opacity: _isEditing ? 0.0 : 1.0, child: ModalGrabber())` 패턴과 동일
  - 생성 모달은 항상 숨김이므로 opacity 고정 0.0

## ✅ Phase 6: 유효성 강화 + 요금 자동 계산 (2026-05-19, 커밋 bdaab8e)

### 6-1: _isValid 연락처 필수 추가
- [x] `_isValid`: `_phoneController.text.trim().isNotEmpty` 조건 추가
  - 기존: 예약자명 + 인원수 → 변경: 예약자명 + 인원수 + **연락처** 모두 비어있지 않아야 활성화
- [x] `_phoneController`에 `onChanged: (_) => setState(() {})` 추가

### 6-2: 생성 초기값 수정
- [x] `home_screen.dart` `_onAddReservation`: `headCount: 1` → `headCount: 0` 변경
  - `_initFields`에서 `headCount > 0`일 때만 채우므로 이제 인원 필드가 빈 상태로 시작

### 6-3: ConsumerStatefulWidget 전환
- [x] `StatefulWidget` → `ConsumerStatefulWidget`, `State` → `ConsumerState`
- [x] `flutter_riverpod` + `home_reservation_actions_controller.dart` import 추가

### 6-4: 요금 자동 계산
- [x] `PriceSetting? _priceSetting` 상태 필드 추가
- [x] `_loadPriceSetting(storeId)`: `initState` + 점포 변경 시 호출
  - `HomeReservationActionsController.getStorePriceSetting(storeId)` 비동기 조회
- [x] `_recalculatePrice()`: `PriceSetting.calculatePrice(start, end, headCount, isAllDay)` 호출 → `_priceController.text` 업데이트
  - 입실/퇴실 시간 변경, 인원 변경, 하루종일 토글, 점포 변경 모두에서 호출

### 관련 Controller 변경 (커밋 4c4ad37, bdaab8e)
- [x] `HomeReservationActionsController.getStorePriceSetting(String storeId) -> Future<PriceSetting?>`
  - `StoreUseCase.getStore(storeId)` → `Store?.priceSettings` 반환
  - `store_use_case_provider.dart` + `price_setting.dart` import 추가
- [x] `HomeReservationActionsController.deleteReservation(Reservation) -> Future<bool>` (별도 Phase)

---

## 미완료/후속 작업

- [ ] 예약 생성 실패 시 사용자 피드백 UI (현재: 로그만 출력, 모달은 닫힘)
- [x] ~~`availableStores` 실제 점포 데이터 연동~~ → reservation-detail-modal Phase 22에서 완료 ✅
- [ ] 예약 생성 후 해당 날짜로 캘린더 스크롤 이동 (UX 개선)
