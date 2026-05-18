# 예약 실시간 스트림 전환 — 태스크

Last Updated: 2026-05-19 (코드 구현 완료, 실기기 검증 대기)

## Phase 1 — DataSource [M]

- [x] `ReservationDataSource` 인터페이스에 `watchReservationsByDateRange` 메서드 추가
- [x] `ReservationFirestoreDataSource`에 구현 추가 (`.snapshots()` + `.handleError`)

## Phase 2 — Repository [M]

- [x] `ReservationRepository` 인터페이스에 `watchReservationsByDateRange` 메서드 추가
- [x] `ReservationRepositoryImpl`에 구현 추가 (`.asyncMap` 엔티티 변환)

## Phase 3 — UseCase [M]

- [x] `ReservationUseCase` 인터페이스에 `watchReservationsByDateRange` 추가
- [x] `ReservationUseCaseImpl`에 구현 추가 (`Stream.fromFuture + asyncExpand + fold`)

## Phase 4 — Provider 재구성 [L]

- [x] `storeReservationsStreamProvider` 추가 (family StreamProvider)
- [x] `homeReservationsProvider` 재구성 (스트림 `.future` watch 패턴)
- [x] `HomeReservationActionsController`에서 `ref.invalidate(homeReservationsProvider)` 제거
- [x] 미사용 import 제거

## Phase 5 — 빌드 및 검증 [S]

- [x] `dart run build_runner build --delete-conflicting-outputs` 실행
- [x] `dart analyze` — No issues found
- [ ] 앱 실행 후 예약 생성 → 캘린더 자동 반영 확인
- [ ] 다른 기기(또는 Firebase 콘솔)에서 예약 변경 → 캘린더 반영 확인
- [ ] `AsyncError` 케이스 (네트워크 끊김 등) UI 처리 확인

---

## 완료 기준

- [x] 모든 Phase 태스크 체크
- [x] `dart analyze` 클린
- [ ] 실기기에서 실시간 갱신 동작 확인
