# Space Options — 핵심 파일 및 의존성

Last Updated: 2026-05-23

## 변경 대상 파일 (레이어별)

### Domain Layer
| 파일 | 변경 내용 |
|------|----------|
| `lib/domain/entities/space_option.dart` | **신규** — SpaceOption 엔티티 (id, name, priceSetting) |
| `lib/domain/entities/store.dart` | `priceSettings` → `spaceOptions: List<SpaceOption>` |
| `lib/domain/entities/reservation.dart` | `spaceOptionId: String?` 추가 |

### Data Layer
| 파일 | 변경 내용 |
|------|----------|
| `lib/data/models/space_option_model.dart` | **신규** — SpaceOptionModel (fromJson/toJson/toEntity/fromEntity) |
| `lib/data/models/store_model.dart` | `priceSettingsModel` → `spaceOptionModels`, 하위 호환 fromJson |
| `lib/data/models/reservation_model.dart` | `spaceOptionId: String?` 추가 |

### Domain UseCase
| 파일 | 변경 내용 |
|------|----------|
| `lib/domain/use_cases/reservation_use_case.dart` | `_applyCalculatedPrice`: 공간별 PriceSetting 분기 |

### Presentation — Store Form
| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/commons/store_input/controllers/states/store_form_state.dart` | `priceSettings` → `spaceOptions: List<SpaceOption>` |
| `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` | DayGroup 메서드에 `spaceIndex` 추가, SpaceOption CRUD 신규 |
| `lib/presentation/commons/store_input/screens/store_form_screen.dart` | SpaceOption 목록 렌더링, 공간 추가/삭제 UI |
| `lib/presentation/commons/store_input/screens/price_days_input_screen.dart` | route extra에 `spaceIndex` 추가 |
| `lib/presentation/commons/store_input/screens/price_time_input_screen.dart` | route extra에 `spaceIndex` 추가 |
| `lib/presentation/commons/store_input/widgets/price_setting_input_form.dart` | `spaceIndex` 전달 |

### Presentation — 예약 모달
| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | 공간 선택 팝업, `_spaceOptionId` 상태 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | 공간 이름 표시 |
| `lib/presentation/providers/home_reservation_actions_controller.dart` | `getStorePriceSetting` → spaceOptionId 기반으로 개선 |

---

## 핵심 현재 구조

### `PriceSetting` (변경 없음, SpaceOption 내부에서 사용)
```
lib/domain/entities/price_setting.dart
lib/data/models/price_settings_model.dart
```
- `PriceSetting.calculatePrice(start, end, headCount, isAllDay, isHoliday)` 메서드는 그대로 유지

### 현재 `Store` → `Reservation` 가격 계산 흐름
```
ReservationUseCaseImpl._applyCalculatedPrice(reservation)
  → _storeRepository.getStore(reservation.storeSummary.id)
  → store.priceSettings.calculatePrice(...)   ← 여기를 spaceOptionId 기반으로 변경
```

### 현재 UI 가격 계산 흐름 (모달)
```
ReservationCreateModal._loadPriceSetting(storeId)
  → HomeReservationActionsController.getStorePriceSetting(storeId)
    → storeUseCase.getStore(storeId)
    → store.priceSettings   ← 반환
→ _recalculatePrice()
```

---

## 주요 설계 결정

### SpaceOption ID 생성 방식
- `uuid` 패키지 사용 또는 Firestore DocumentReference의 ID 패턴 모방
- 클라이언트에서 생성: `DateTime.now().millisecondsSinceEpoch.toString()` 또는 `nanoid`
- 단순하게: `uuid` v4 (이미 프로젝트에 있는지 확인 필요) 또는 `FirebaseFirestore.instance.collection('_').doc().id`

### `StoreFormState.spaceOptions` 초기값
- 생성 모드: `[SpaceOption(id: 생성, name: '기본 공간', priceSetting: PriceSetting.empty())]`
- 수정 모드: `store.spaceOptions`에서 변환

### 하위 호환 처리 (StoreModel.fromJson)
```dart
factory StoreModel.fromJson(Map<String, dynamic> json) {
  // spaceOptions가 있으면 그대로 사용
  if (json.containsKey('spaceOptions')) {
    return _$StoreModelFromJson(json);
  }
  // 없으면 priceSettingsModel에서 마이그레이션
  final priceSettingsJson = json['priceSettingsModel'];
  json['spaceOptions'] = [
    {'id': 'default', 'name': '기본 공간', 'priceSettings': priceSettingsJson ?? {'dayGroupModels': []}}
  ];
  return _$StoreModelFromJson(json);
}
```

### 공간이 1개일 때 예약 모달 처리
- 공간이 1개이면 선택 UI 숨김, `spaceOptionId`는 자동으로 첫 번째 공간의 id 사용
- 공간이 2개 이상이면 선택 UI 표시

---

## 코드 생성 주의사항

아래 파일들을 수정한 후 반드시 코드 생성 실행:
```bash
dart run build_runner build --delete-conflicting-outputs
```

영향받는 `.freezed.dart` 및 `.g.dart`:
- `space_option.freezed.dart` (신규)
- `space_option_model.freezed.dart`, `space_option_model.g.dart` (신규)
- `store.freezed.dart`
- `store_model.freezed.dart`, `store_model.g.dart`
- `reservation.freezed.dart`
- `reservation_model.freezed.dart`, `reservation_model.g.dart`
- `store_form_state.freezed.dart`
