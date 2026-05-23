# Space Options — 작업 체크리스트

Last Updated: 2026-05-23

## Phase 1: Domain Layer ✅

- [x] **1-1** `SpaceOption` 엔티티 신규 생성
- [x] **1-2** `Store` 엔티티 수정 (`priceSettings` → `spaceOptions`, `priceSettingForSpace` getter)
- [x] **1-3** `Reservation` 엔티티 수정 (`spaceOptionId: String?`)
- [x] **1-4** 코드 생성 및 `dart analyze` 통과

---

## Phase 2: Data Layer ✅

- [x] **2-1** `SpaceOptionModel` 신규 생성 (`lib/data/models/space_option_model.dart`)
- [x] **2-2** `StoreModel` 수정
  - `priceSettingsModel` → `spaceOptions: List<SpaceOptionModel>`
  - 하위 호환 처리: `StoreDataSource._migrateToSpaceOptions()` (DataSource 레이어)
- [x] **2-3** `ReservationModel` 수정 (`spaceOptionId: String?`)
- [x] **2-4** 코드 생성 및 빌드 확인

---

## Phase 3: UseCase ✅

- [x] **3-1** `ReservationUseCaseImpl._applyCalculatedPrice`
  - `store.priceSettings` → `store.priceSettingForSpace(reservation.spaceOptionId)`
- [x] **3-2** `dart analyze` 통과

---

## Phase 4: Presentation — Store Form ✅

- [x] **4-1** `StoreFormState` (`priceSettings` → `spaceOptions: List<SpaceOption>`)
- [x] **4-2** `StoreFormControllerable/Mixin`
  - DayGroup 메서드에 `spaceIndex` 파라미터 추가
  - SpaceOption CRUD 신규: `addSpaceOption`, `removeSpaceOption`, `setSpaceOptionName`, `copySpaceOption`
- [x] **4-3** `StoreCreationController`, `StoreUpdateController` 수정
- [x] **4-4** `StoreFormScreen`: SpaceOption 루프, 공간명 입력, 공간 추가/삭제/복사 버튼
- [x] **4-5** `PriceDaysInputScreen`: `spaceIndex/groupIndex` 파라미터 전환
- [x] **4-6** `PriceTimeInputScreen`: `spaceIndex/groupIndex` 파라미터 전환
- [x] **4-7** `PriceSettingInputForm`: 콜백 via StoreFormScreen (위젯 자체는 변경 불필요)
- [x] **4-8** 코드 생성 및 빌드 확인

---

## Phase 5: Presentation — 예약 모달 ✅

- [x] **5-1** `ReservationCreateModal`
  - `_priceSetting` → `_spaceOptions + _spaceOptionId`
  - `_loadSpaceOptions()` / `_recalculatePrice()` 공간 기반으로 전환
  - `spaceOptionId` 예약에 포함
- [x] **5-2** `ReservationDetailModal` (동일한 패턴 적용)
- [x] **5-3** `HomeReservationActionsController`
  - `getStorePriceSetting` → `getStoreSpaceOptions(storeId): List<SpaceOption>?`

---

## Phase 6: 최종 검증

- [x] **6-1** `dart analyze` 오류 없음 확인
- [ ] **6-2** 점포 생성 플로우 수동 테스트 (공간 2개 이상 생성)
- [ ] **6-3** 점포 수정 플로우 수동 테스트 (기존 단일 공간 점포)
- [ ] **6-4** 예약 생성 시 공간 선택 및 요금 자동 계산 확인
- [ ] **6-5** 기존 Firestore 데이터 (priceSettingsModel 구조) 읽기 정상 동작 확인
- [ ] **6-6** 기존 예약 (spaceOptionId 없음) 조회 정상 동작 확인

---

## 참고

- 계획 상세: `space-options-plan.md`
- 핵심 파일/의존성: `space-options-context.md`
- 공휴일 요금 TODO는 이 작업과 별도로 유지 (`isHoliday: false` 고정 유지)
- 예약 모달에서 공간 선택 UI (다중 공간 시 팝업) 구현은 향후 Phase로 분리 가능
