# Space Options (공간 옵션) 기능 계획

Last Updated: 2026-05-23

## 요약

현재 한 점포당 단일 `PriceSetting`만 가질 수 있는 구조를, **복수의 공간 옵션(SpaceOption)**을 지원하도록 확장한다.
각 공간 옵션은 독립적인 이름(`name`)과 요금 설정(`PriceSetting`)을 가지며, 예약 시 특정 공간을 선택할 수 있다.

예: "메인 홀", "스튜디오 컨셉 방" 등이 각각 다른 요금 정책을 가지는 구조.

---

## 현재 상태

```
Store.priceSettings: PriceSetting          ← 단일 요금 설정
  └── List<DayGroup>                        ← 요일 그룹
        └── List<TimeSlot> + HeadcountRule

Reservation.storeSummary: StoreSummary     ← 공간 정보 없음
_applyCalculatedPrice() → store.priceSettings.calculatePrice(...)
```

**문제점:**
- 점포 내 공간이 여러 개일 때 공간별 요금을 별도 설정할 수 없다
- 예약이 어느 공간인지 구분되지 않는다

---

## 목표 상태

```
Store.spaceOptions: List<SpaceOption>      ← 복수 공간 옵션
  └── SpaceOption
        ├── id: String                     ← 고유 식별자
        ├── name: String                   ← 공간 이름 (예: "메인 홀")
        └── priceSetting: PriceSetting     ← 공간별 요금 설정

Reservation.spaceOptionId: String?         ← 선택한 공간 ID (null = 단일 공간 또는 미지정)
_applyCalculatedPrice() → 해당 공간의 priceSetting.calculatePrice(...)
```

---

## Firestore 구조 변경

### Before
```json
{
  "name": "...",
  "priceSettingsModel": {
    "dayGroupModels": [...]
  }
}
```

### After
```json
{
  "name": "...",
  "spaceOptions": [
    { "id": "abc123", "name": "메인 홀",    "priceSettings": { "dayGroupModels": [...] } },
    { "id": "def456", "name": "스튜디오",   "priceSettings": { "dayGroupModels": [...] } }
  ]
}
```

### 하위 호환 전략
- `StoreModel.fromJson` 에서: `spaceOptions` 키가 없고 `priceSettingsModel`이 있으면 → "기본 공간" 단일 SpaceOption으로 자동 변환
- `Reservation.spaceOptionId == null` → 첫 번째 공간 옵션의 PriceSetting을 사용

---

## Phase 별 구현 계획

### Phase 1: Domain Layer (가장 먼저, 다른 레이어 기반)

#### 1-1. `SpaceOption` 엔티티 신규 생성
파일: `lib/domain/entities/space_option.dart`
```dart
@freezed
abstract class SpaceOption with _$SpaceOption {
  const factory SpaceOption({
    required String id,
    required String name,
    required PriceSetting priceSetting,
  }) = _SpaceOption;

  factory SpaceOption.empty() => SpaceOption(
    id: '', name: '', priceSetting: PriceSetting.empty(),
  );
}
```

#### 1-2. `Store` 엔티티 수정
- `priceSettings: PriceSetting` → `spaceOptions: List<SpaceOption>`
- 편의 getter 추가: `PriceSetting? priceSettingForSpace(String? spaceOptionId)` — spaceOptionId로 찾거나 첫 번째 반환

#### 1-3. `Reservation` 엔티티 수정
- `spaceOptionId: String?` 필드 추가

---

### Phase 2: Data Layer

#### 2-1. `SpaceOptionModel` 신규 생성
파일: `lib/data/models/space_option_model.dart`
- `@freezed` + `fromJson/toJson` + `toEntity/fromEntity`

#### 2-2. `StoreModel` 수정
- `priceSettingsModel` 필드 제거, `spaceOptionModels: List<SpaceOptionModel>` 추가
- `fromJson`: `spaceOptions` 키 없으면 `priceSettingsModel`에서 하위 호환 변환
- `toEditableJson()`: `priceSettingsModel` → `spaceOptions`로 키 변경
- `toEntity/fromEntity` 업데이트

#### 2-3. `ReservationModel` 수정
- `spaceOptionId: String?` 필드 추가

---

### Phase 3: UseCase

#### 3-1. `ReservationUseCaseImpl._applyCalculatedPrice` 수정
```dart
final priceSetting = store.priceSettingForSpace(reservation.spaceOptionId);
if (priceSetting == null) return reservation; // 매칭 없으면 유지
final calculatedPrice = priceSetting.calculatePrice(...);
```

---

### Phase 4: Presentation — Store Form

이 페이즈가 가장 변경량이 크다.

#### 4-1. `StoreFormState` 수정
- `priceSettings: PriceSetting` → `spaceOptions: List<SpaceOption>`

#### 4-2. `StoreFormControllerable` / `StoreFormMixin` 수정
- 기존 DayGroup 메서드에 `spaceIndex` 파라미터 추가:
  - `addDayGroup(int spaceIndex)`
  - `removeDayGroup(int spaceIndex, int groupIndex)`
  - `copyDayGroup(int spaceIndex, int groupIndex)`
  - `toggleDayGroupDay(int spaceIndex, int groupIndex, Weekday day)`
  - `setDayGroup(int spaceIndex, int groupIndex, DayGroup dayGroup)`
  - `addTimeSlot(int spaceIndex, int groupIndex)`
  - `copyTimeSlot(int spaceIndex, int groupIndex, int slotIndex)`
  - `removeTimeSlot(int spaceIndex, int groupIndex, int slotIndex)`
- 신규 SpaceOption 메서드 추가:
  - `addSpaceOption()`
  - `removeSpaceOption(int spaceIndex)`
  - `setSpaceOptionName(int spaceIndex, String name)`
  - `copySpaceOption(int spaceIndex)`

#### 4-3. `StoreFormScreen` 수정
- `priceSettings.dayGroups` 루프 → `spaceOptions` 루프로 변경
- 각 SpaceOption: 이름 입력 + 그 안에 DayGroup 목록 표시
- SpaceOption 추가/삭제/복사 UI

#### 4-4. `PriceDaysInputScreen`, `PriceTimeInputScreen` 수정
- Route `extra`에 `spaceIndex` 파라미터 추가: `{'store': ..., 'spaceIndex': si, 'groupIndex': gi}`
- 컨트롤러 메서드 호출 시 `spaceIndex` 전달

#### 4-5. `PriceSettingInputForm` 위젯 수정
- `onPressedDaySetting`, `onPressedTimeSetting` 콜백에 `spaceIndex` 정보 전달

---

### Phase 5: Presentation — 예약 모달

#### 5-1. `ReservationCreateModal` 수정
- 공간 선택 팝업 추가 (점포 spaceOptions가 2개 이상일 때)
- `_spaceOptionId: String?` 상태 추가
- `_recalculatePrice()`: `priceSetting` 로드를 공간별로 분기

#### 5-2. `ReservationDetailModal` 수정
- 공간 이름 표시 (공간 선택이 있는 경우)

#### 5-3. `HomeReservationActionsController` 수정
- `getStorePriceSetting(storeId)` → `getSpacePriceSetting(storeId, spaceOptionId)` 또는
  `getStore(storeId)` 후 UI에서 spaceOptionId로 직접 필터링 방식으로 변경

---

## 위험 요소 및 대응

| 위험 | 대응 |
|------|------|
| 기존 Firestore 문서에 `spaceOptions` 키 없음 | `StoreModel.fromJson`에서 `priceSettingsModel` 폴백 처리 |
| 기존 예약에 `spaceOptionId` 없음 | `String?` nullable로 선언, 계산 시 첫 번째 공간 폴백 |
| `StoreFormMixin` 메서드 시그니처 전면 변경 | `PriceDaysInputScreen`, `PriceTimeInputScreen` route extra 파라미터도 함께 변경 |
| `store.priceSettings` 참조 전체 제거 | 검색으로 모든 참조 확인 후 일괄 수정 |

---

## 검색으로 찾아야 할 참조 목록

변경 전 `store.priceSettings`를 참조하는 코드:
- `lib/domain/use_cases/reservation_use_case.dart` ← `_applyCalculatedPrice`
- `lib/presentation/home/widgets/.../reservation_create_modal.dart`
- `lib/presentation/home/widgets/.../reservation_detail_modal.dart`
- `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart`
- `lib/presentation/commons/store_input/controllers/states/store_form_state.dart`
- `lib/presentation/commons/store_input/screens/store_form_screen.dart`
- `lib/presentation/commons/store_input/screens/price_days_input_screen.dart`
- `lib/presentation/commons/store_input/screens/price_time_input_screen.dart`

---

## 성공 기준

1. 점포 생성/수정 화면에서 공간 옵션 여러 개를 이름과 함께 설정할 수 있다
2. 예약 생성 시 공간 옵션을 선택할 수 있으며, 선택한 공간의 요금이 자동 계산된다
3. 공간이 1개인 경우 (기존 점포 포함) 하위 호환되어 정상 동작한다
4. `dart analyze` 통과, 빌드 오류 없음
