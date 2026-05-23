# Space Options — 작업 체크리스트

Last Updated: 2026-05-23

## Phase 1: Domain Layer

- [ ] **1-1** `SpaceOption` 엔티티 신규 생성
  - 파일: `lib/domain/entities/space_option.dart`
  - 필드: `id: String`, `name: String`, `priceSetting: PriceSetting`
  - `SpaceOption.empty()` 팩토리 메서드 포함
  - AC: `@freezed` 어노테이션, part 파일 포함

- [ ] **1-2** `Store` 엔티티 수정
  - 파일: `lib/domain/entities/store.dart`
  - `priceSettings: PriceSetting` → `spaceOptions: List<SpaceOption>`
  - `PriceSetting? priceSettingForSpace(String? spaceOptionId)` getter 추가
    - spaceOptionId가 null이거나 못 찾으면 첫 번째 공간 반환
  - AC: 기존 `priceSettings` 참조 모두 제거

- [ ] **1-3** `Reservation` 엔티티 수정
  - 파일: `lib/domain/entities/reservation.dart`
  - `spaceOptionId: String?` 필드 추가 (nullable, 기본값 null)
  - AC: `@Default(null)` 사용

- [ ] **1-4** 코드 생성 실행 및 빌드 확인
  - `dart run build_runner build --delete-conflicting-outputs`
  - `dart analyze` 통과 확인

---

## Phase 2: Data Layer

- [ ] **2-1** `SpaceOptionModel` 신규 생성
  - 파일: `lib/data/models/space_option_model.dart`
  - `@freezed` + `fromJson` + `toJson`
  - `toEntity()`, `fromEntity(SpaceOption)` 메서드
  - 필드: `id: String`, `name: String`, `priceSettings: PriceSettingsModel`

- [ ] **2-2** `StoreModel` 수정
  - 파일: `lib/data/models/store_model.dart`
  - `priceSettingsModel` 필드 제거
  - `spaceOptionModels: List<SpaceOptionModel>` 추가 (`@Default([])`)
  - `fromJson` 하위 호환 처리:
    - `spaceOptions` 키 없고 `priceSettingsModel`이 있으면 "기본 공간" SpaceOptionModel 생성
  - `toEditableJson()`: `spaceOptions` 키로 직렬화
  - `toEntity`, `fromEntity` 업데이트
  - AC: 기존 Firestore 문서(priceSettingsModel 구조)를 읽어도 정상 동작

- [ ] **2-3** `ReservationModel` 수정
  - 파일: `lib/data/models/reservation_model.dart`
  - `spaceOptionId: String?` 필드 추가 (`@Default(null)`)
  - `toEntity`, `fromEntity` 업데이트
  - AC: 기존 예약 데이터(spaceOptionId 없음)도 null로 읽힘

- [ ] **2-4** 코드 생성 실행 및 빌드 확인

---

## Phase 3: UseCase

- [ ] **3-1** `ReservationUseCaseImpl._applyCalculatedPrice` 수정
  - 파일: `lib/domain/use_cases/reservation_use_case.dart`
  - `store.priceSettings` → `store.priceSettingForSpace(reservation.spaceOptionId)`
  - priceSetting이 null이면 기존 값 유지(반환)
  - AC: 기존 동작 유지, 공간별 요금 계산 분기

- [ ] **3-2** `dart analyze` 통과 확인

---

## Phase 4: Presentation — Store Form

- [ ] **4-1** `StoreFormState` 수정
  - 파일: `lib/presentation/commons/store_input/controllers/states/store_form_state.dart`
  - `priceSettings: PriceSetting` → `spaceOptions: List<SpaceOption>`
  - 기본값: `@Default([])` (컨트롤러 init에서 적절한 초기값 설정)

- [ ] **4-2** `StoreFormControllerable` / `StoreFormMixin` 수정
  - 파일: `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart`
  - 기존 DayGroup 메서드 시그니처에 `int spaceIndex` 파라미터 추가
  - SpaceOption 관리 신규 메서드:
    - `addSpaceOption()`: 빈 SpaceOption 추가, id 생성
    - `removeSpaceOption(int spaceIndex)`: 마지막 하나면 초기화
    - `setSpaceOptionName(int spaceIndex, String name)`
    - `copySpaceOption(int spaceIndex)`: 이름은 "(복사)" 접미사

- [ ] **4-3** `StoreCreationController`, `StoreUpdateController` 수정
  - DayGroup 메서드 호출 시 `spaceIndex` 전달
  - 초기 `spaceOptions` 값 설정

- [ ] **4-4** `StoreFormScreen` 수정
  - 파일: `lib/presentation/commons/store_input/screens/store_form_screen.dart`
  - `priceSettings.dayGroups` 루프 → `spaceOptions` 루프
  - 각 SpaceOption 섹션: 이름 입력 텍스트필드 + DayGroup 목록
  - SpaceOption 추가/삭제 버튼
  - route extra에 `spaceIndex` 추가

- [ ] **4-5** `PriceDaysInputScreen` 수정
  - 파일: `lib/presentation/commons/store_input/screens/price_days_input_screen.dart`
  - route extra: `{'store': ..., 'spaceIndex': si, 'groupIndex': gi}`
  - 컨트롤러 메서드 호출에 `spaceIndex` 전달

- [ ] **4-6** `PriceTimeInputScreen` 수정
  - 파일: `lib/presentation/commons/store_input/screens/price_time_input_screen.dart`
  - 동일하게 `spaceIndex` 추가

- [ ] **4-7** `PriceSettingInputForm` 수정
  - 파일: `lib/presentation/commons/store_input/widgets/price_setting_input_form.dart`
  - `spaceIndex` 콜백 파라미터 업데이트

- [ ] **4-8** 코드 생성 및 빌드 확인

---

## Phase 5: Presentation — 예약 모달

- [ ] **5-1** `ReservationCreateModal` 수정
  - 파일: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`
  - `_spaceOptionId: String?` 로컬 상태 추가
  - `_loadPriceSetting`: 점포의 공간 목록도 함께 로드
  - 공간 2개 이상 시 공간 선택 팝업 UI 추가
  - `_recalculatePrice`: 선택된 `_spaceOptionId` 기반 priceSetting 사용
  - `_buildReservation()`: `spaceOptionId` 포함

- [ ] **5-2** `ReservationDetailModal` 수정
  - 파일: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`
  - 공간 이름 표시 (spaceOptionId → 공간명 조회 또는 reservation에 직접 포함 검토)

- [ ] **5-3** `HomeReservationActionsController` 수정
  - 파일: `lib/presentation/providers/home_reservation_actions_controller.dart`
  - `getStorePriceSetting(storeId)` 반환 타입을 `(List<SpaceOption> spaces)` 또는
    Store 자체로 변경하는 방안 검토
  - AC: 모달에서 공간 선택 후 해당 공간의 priceSetting으로 요금 계산 가능

---

## Phase 6: 최종 검증

- [ ] **6-1** `dart analyze` 오류 없음 확인
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
