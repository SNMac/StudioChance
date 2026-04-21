# Use Case 개선 — 작업 체크리스트

Last Updated: 2026-04-21

---

## Phase 1 — Use Case Stub 연결 ✅ (완료)

- [x] **[STUB-1]** `UserUseCaseImpl.updateStoreInfo` — `_repository.updateStoreInfo(...)` 위임 연결
  - 파일: `lib/domain/use_cases/user_use_case.dart`
  - 이전: `Future.value(left(Exception('UserRepository 업데이트 필요')))`
  - 이후: `_repository.updateStoreInfo(uid: uid, storeId: storeId, name: name, color: color)`

- [x] **[STUB-2]** `StoreUseCaseImpl.updateMemberRole` — `_storeRepository.updateMemberRole(...)` 위임 연결
  - 파일: `lib/domain/use_cases/store_use_case.dart`
  - 이전: `TaskEither.left(Exception('기능 구현 예정')).run()`
  - 이후: `TaskEither(() => _storeRepository.updateMemberRole(...)).run()`

---

## Phase 2 — PriceSetting 가격 계산 도메인 로직

### 2-1. `PriceSetting` 엔티티 — calculatePrice 메서드 추가 ✅
- [x] `lib/domain/entities/price_setting.dart`에 `const PriceSetting._()` 추가
- [x] `calculatePrice({required DateTime start, required DateTime end, required int headCount, bool isAllDay = false})` 구현
  - 요일 → DayGroup 매칭 (없으면 0 반환)
  - isAllDay 분기 처리
  - startTime 분 단위 변환 → TimeSlot 매칭 (없으면 0 반환)
  - 기본 요금 계산 (isHourly, isPerPerson)
  - 인원 추가 요금 계산 (headcountBase 초과분, isHeadcountHourly)
  - return basePrice + extraCharge
- [x] `dart run build_runner build --delete-conflicting-outputs` 성공

### 2-2. `ReservationUseCase` — `StoreRepository` 의존성 추가 ✅
- [x] `lib/domain/use_cases/reservation_use_case.dart`
  - `ReservationUseCaseImpl` 생성자에 `StoreRepository` 추가
  - `reservationUseCaseProvider`에서 `storeRepositoryProvider` 주입

### 2-3. `ReservationUseCase.createReservation` — 가격 자동 계산 ✅
- [x] `_applyCalculatedPrice` private 헬퍼 추가
  - `_storeRepository.getStore(reservation.storeSummary.id)` 호출
  - store가 null이거나 실패 시 → 기존 값 유지 (에러로 처리 안 함)
  - `priceSettings.calculatePrice(start, end, headCount, isAllDay)` 호출
  - `reservation.copyWith(calculatedPrice: ..., totalPrice: ...)` 반영 후 저장
- [x] `createReservation` — `_applyCalculatedPrice` 적용 (writer 설정 전에 호출)

### 2-4. `ReservationUseCase.updateReservation` — 가격 재계산 ✅
- [x] `updateReservation` — `_applyCalculatedPrice` 적용 후 repository 전달

### 2-5. 기존 테스트 업데이트 ✅
- [x] `test/domain/use_cases/reservation_use_case_test.dart`
  - `MockStoreRepository` 추가
  - setUp에 기본 stub: `getStore()` → `right(null)` (가격 계산 스킵)
  - `storeRepository: mockStoreRepo` 생성자 인자 추가

---

## 완료 기준

- [x] `PriceSetting.calculatePrice()` — DayGroup/TimeSlot 매칭 후 정확한 금액 반환
- [x] PriceSetting이 비어있거나 매칭 실패 시 0 반환 (에러 없음)
- [x] `createReservation` 저장 데이터에 계산된 `calculatedPrice`, `totalPrice` 포함
- [x] `updateReservation` 저장 데이터에 재계산된 `calculatedPrice`, `totalPrice` 포함
- [x] `dart analyze` 에러 없음
- [x] `flutter test` 기존 테스트 전체 통과 (66개 전체 통과, Timestamp 이슈 근본 수정 완료)
