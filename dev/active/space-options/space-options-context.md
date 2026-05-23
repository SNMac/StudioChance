# Space Options — 핵심 파일 및 의존성

Last Updated: 2026-05-23

---

## 현재 구현 상태

**Phase 1~5 구현 완료. `dart analyze` 오류 0개. 커밋 완료.**

- 커밋: `f0bb5e4` — 전체 레이어 구현 (32파일)
- 커밋: `1b0f1e1` — tasks.md 업데이트

**A-1/A-2 완료. 남은 작업: Phase 6 수동 테스트 (앱 실행 후 확인)**

---

## 중요 결정 사항

### 1. 하위 호환 불필요
앱이 아직 배포되지 않아 기존 Firestore 문서 호환이 필요 없음.
`StoreDataSource._migrateToSpaceOptions()`는 존재하지만 실제로 필요 없음 → 향후 정리 가능.

### 2. `StoreModel.fromJson` 오버라이드 불가
처음에 `StoreModel.fromJson`에서 직접 하위 호환 처리를 시도했으나, Freezed + json_serializable 구조에서 `fromJson` 오버라이드 시 `.g.dart` 파일이 생성되지 않는 문제 발생.
→ 해결: 하위 호환 변환 로직을 `StoreFirestoreDataSource._migrateToSpaceOptions()`로 이동.

### 3. SpaceOption ID 생성
`DateTime.now().millisecondsSinceEpoch.toString()` 방식 사용 (uuid 패키지 없음).

### 4. 예약 모달 공간 선택 UI ✅ 구현 완료
`ReservationCreateModal._buildSection1()`, `ReservationDetailModal._buildSection1Edit()`에
`TitlePopupButton<SpaceOption>` 추가 완료 (공간 2개 이상일 때만 표시).
`ReservationDetailModal._buildSection1ReadOnly()`에도 공간 이름 표시 추가.
`_resetFields()`에 `_spaceOptionId = r.spaceOptionId` 추가 (편집 취소 시 복원).

---

## 변경된 파일 목록

### 신규 생성
| 파일 | 설명 |
|------|------|
| `lib/domain/entities/space_option.dart` | SpaceOption 엔티티 |
| `lib/domain/entities/space_option.freezed.dart` | 생성됨 |
| `lib/data/models/space_option_model.dart` | SpaceOptionModel |
| `lib/data/models/space_option_model.freezed.dart` | 생성됨 |
| `lib/data/models/space_option_model.g.dart` | 생성됨 |

### 수정된 Domain
| 파일 | 변경 내용 |
|------|----------|
| `lib/domain/entities/store.dart` | `priceSettings` → `spaceOptions: List<SpaceOption>`, `priceSettingForSpace(String?)` getter |
| `lib/domain/entities/reservation.dart` | `spaceOptionId: String?` 추가 |
| `lib/domain/use_cases/reservation_use_case.dart` | `_applyCalculatedPrice`: `priceSettingForSpace()` 사용 |

### 수정된 Data
| 파일 | 변경 내용 |
|------|----------|
| `lib/data/models/store_model.dart` | `priceSettingsModel` → `spaceOptions: List<SpaceOptionModel>` |
| `lib/data/models/reservation_model.dart` | `spaceOptionId: String?` 추가 |
| `lib/data/data_sources/store_data_source.dart` | `_migrateToSpaceOptions()` 헬퍼 추가 (getStore, getStoreByInviteCode에서 호출) |

### 수정된 Presentation
| 파일 | 변경 내용 |
|------|----------|
| `lib/presentation/commons/store_input/controllers/states/store_form_state.dart` | `priceSettings` → `spaceOptions: List<SpaceOption>` |
| `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` | DayGroup 메서드에 `spaceIndex` 추가, SpaceOption CRUD 신규 |
| `lib/presentation/commons/store_input/controllers/store_creation_controller.dart` | 초기 spaceOptions 생성 (id 자동, name '기본 공간') |
| `lib/presentation/commons/store_input/controllers/store_update_controller.dart` | `store.spaceOptions`에서 초기화 |
| `lib/presentation/commons/store_input/screens/store_form_screen.dart` | SpaceOption 루프 렌더링, `_SpaceOptionButtonRow` 위젯 추가 |
| `lib/presentation/commons/store_input/screens/price_days_input_screen.dart` | route extra: `{spaceIndex, groupIndex}` |
| `lib/presentation/commons/store_input/screens/price_time_input_screen.dart` | route extra: `{spaceIndex, groupIndex}`, `notifier.setDayGroup(si, gi, dg)` |
| `lib/presentation/providers/home_reservation_actions_controller.dart` | `getStorePriceSetting` → `getStoreSpaceOptions(): List<SpaceOption>?` |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | `_priceSetting` → `_spaceOptions + _spaceOptionId`, `_loadSpaceOptions()` |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | 동일 패턴 |

---

## 핵심 현재 구조

```
Store.spaceOptions: List<SpaceOption>
  └── SpaceOption { id, name, priceSetting: PriceSetting }
        └── PriceSetting { dayGroups: List<DayGroup> }
              └── DayGroup { days, headcountRule, timeSlots }

Reservation.spaceOptionId: String?    ← null = 첫 번째 공간 폴백
```

### 가격 계산 흐름 (서버 측)
```
ReservationUseCaseImpl._applyCalculatedPrice(reservation)
  → _storeRepository.getStore(storeId)
  → store.priceSettingForSpace(reservation.spaceOptionId)
  → priceSetting.calculatePrice(...)
```

### 가격 계산 흐름 (모달 UI)
```
ReservationCreateModal._loadSpaceOptions(storeId)
  → HomeReservationActionsController.getStoreSpaceOptions(storeId)
  → _spaceOptions = List<SpaceOption>
  → _spaceOptionId = 첫 번째 공간 id (또는 기존 reservation.spaceOptionId)
→ _recalculatePrice(): _spaceOptions에서 _spaceOptionId로 PriceSetting 조회
```

### StoreFormMixin DayGroup 메서드 (변경된 시그니처)
```dart
addDayGroup(int spaceIndex)
copyDayGroup(int spaceIndex, int groupIndex)
removeDayGroup(int spaceIndex, int groupIndex)
toggleDayGroupDay(int spaceIndex, int groupIndex, Weekday day)
setDayGroup(int spaceIndex, int groupIndex, DayGroup dayGroup)
addTimeSlot(int spaceIndex, int groupIndex)
copyTimeSlot(int spaceIndex, int groupIndex, int slotIndex)
removeTimeSlot(int spaceIndex, int groupIndex, int slotIndex)
```

### Route Extra 파라미터 (PriceDays/PriceTime)
```dart
// Before
extra: {'store': widget.storeToEdit, 'index': index}

// After
extra: {'store': widget.storeToEdit, 'spaceIndex': spaceIndex, 'groupIndex': groupIndex}
```

---

## 다음 작업 (Phase 6 — 수동 테스트)

1. **앱 실행** (`flutter run`)
2. 점포 생성 화면에서 공간 추가/삭제/이름 입력 확인
3. 공간별 요일/시간 요금 설정 저장 확인 (Firestore `spaceOptions` 키로 저장되는지)
4. 예약 생성 시 `spaceOptionId` 필드가 저장되는지 확인
5. (선택) 예약 모달에 공간 선택 드롭다운 UI 추가

---

## 코드 생성 명령어

```bash
dart run build_runner build --delete-conflicting-outputs
```
