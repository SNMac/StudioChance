# 예약 등록 버튼 — 태스크 체크리스트

Last Updated: 2026-05-19

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

## 미완료/후속 작업

- [ ] 예약 생성 실패 시 사용자 피드백 UI (현재: 로그만 출력, 모달은 닫힘)
- [ ] `availableStores` 실제 점포 데이터 연동 (현재: `userStoreInfos` 기반 변환)
- [ ] 예약 생성 후 해당 날짜로 캘린더 스크롤 이동 (UX 개선)
