# Use Case 개선 — 컨텍스트

Last Updated: 2026-04-21

---

## 핵심 파일

### Domain — Use Cases (수정 대상)
| 파일 | 역할 | 수정 사항 |
|------|------|----------|
| `lib/domain/use_cases/user_use_case.dart` | 사용자 비즈니스 로직 | [STUB-1] 완료 |
| `lib/domain/use_cases/store_use_case.dart` | 점포 비즈니스 로직 | [STUB-2] 완료 |
| `lib/domain/use_cases/reservation_use_case.dart` | 예약 비즈니스 로직 | Phase 2 전체 완료 |

### Domain — Entities (수정 대상)
| 파일 | 역할 | 수정 사항 |
|------|------|----------|
| `lib/domain/entities/price_setting.dart` | 가격 설정 집합 | Phase 2-1: calculatePrice 추가 완료 |
| `lib/domain/entities/day_group.dart` | 요일 그룹 (days, headcountRule, timeSlots) | 읽기 전용 |
| `lib/domain/entities/time_slot.dart` | 시간대별 요금 (startTime, endTime, price, isHourly, isPerPerson) | 읽기 전용 |
| `lib/domain/entities/headcount_rule.dart` | 인원 추가 요금 규칙 | 읽기 전용 |

### Domain — Enums
| 파일 | 역할 |
|------|------|
| `lib/domain/enums/weekday.dart` | 요일 enum (1=월~7=일, 8=공휴일) |

### Domain — Repository Interfaces
| 파일 | 역할 |
|------|------|
| `lib/domain/repository_interfaces/user_repository.dart` | updateStoreInfo 정의됨 |
| `lib/domain/repository_interfaces/store_repository.dart` | updateMemberRole 정의됨 |
| `lib/domain/repository_interfaces/reservation_repository.dart` | createReservation, updateReservation |

### Data — Repository Implementations
| 파일 | 역할 |
|------|------|
| `lib/data/repositories/user_repository_impl.dart` | updateStoreInfo 구현됨 (line 131) |
| `lib/data/repositories/store_repository_impl.dart` | updateMemberRole 구현됨 (line 239) |
| `lib/data/repositories/reservation_repository_impl.dart` | createReservation, updateReservation 구현됨 |
| `lib/data/repositories/store_repository_impl.dart` | getStore — PriceSetting 포함 |

### Data — Models (이번 세션 수정)
| 파일 | 역할 | 수정 사항 |
|------|------|----------|
| `lib/data/models/reservation_model.dart` | 예약 Data 모델 | `Timestamp` 직접 import 추가 (테스트 컴파일 픽스) |
| `lib/common/converters/timestamp_converter.dart` | Firestore Timestamp ↔ DateTime 변환 | `cloud_firestore show Timestamp`로 명시적 import |

### Test Helpers (이번 세션 신규)
| 파일 | 역할 |
|------|------|
| `test/helpers/fake_entities.dart` | Domain Entity 전용 테스트 픽스처 (cloud_firestore 의존 없음) |
| `test/helpers/fake_models.dart` | Data Model 전용 테스트 픽스처 (Repository 테스트용) |
| `test/helpers/fake_data.dart` | 두 파일의 re-export 허브 (기존 import 호환 유지) |

---

## 핵심 결정 사항

### 1. 가격 계산 위치: PriceSetting 엔티티 + UseCase

```
PriceSetting.calculatePrice()  ← 순수 함수 (도메인 규칙)
       ↓
ReservationUseCase             ← 저장 전 호출 (authoritative)
       ↓
Controller/Widget              ← UI 미리보기 시 동일 메서드 직접 호출 가능
```

**이유**: 가격 계산은 도메인 규칙. Controller는 UI 상태만 담당해야 함.

### 2. 계산 실패 시 0 반환

- DayGroup/TimeSlot 매칭 실패(빈 PriceSetting, 미등록 요일 등)
- 0 반환 → UI에서 사용자가 수동 입력

### 3. `totalPrice` 단순 합산

`totalPrice = calculatedPrice + priceAdjustment`
UseCase에서 항상 재계산하여 저장 (UI가 설정하지 않음).

### 4. UI 미리보기 (현재 스코프 밖)

현재 모달(`reservation_detail_modal.dart`)은 `_priceController`로 수동 입력.
Phase 2에서는 UseCase 저장 시 계산만 보장하고, 실시간 UI 미리보기는 향후 별도 작업.

---

## Timestamp 이슈 근본 수정 (이번 세션)

### 문제

`flutter test` 실행 시 `reservation_use_case_test.dart` 컴파일 실패:
```
lib/data/models/reservation_model.g.dart:21:30: Error: 'Timestamp' isn't a type.
```

### 원인 분석

1. `reservation_model.g.dart`는 `part of reservation_model.dart`이므로 부모 파일의 import 스코프만 사용
2. `reservation_model.dart`는 `timestamp_converter.dart`를 import하지만, Dart는 import를 re-export하지 않음
3. 따라서 `reservation_model.g.dart`에서 `Timestamp`가 스코프에 없음
4. `dart analyze`는 이를 통과시키지만 kernel 컴파일러는 엄격하게 거부

### 해결책

`reservation_model.dart`에 `Timestamp`를 **직접** import 추가:
```dart
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
```

`timestamp_converter.dart`도 명시적으로 필요한 것만 import:
```dart
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
```

### fake_data.dart 분리 (같은 세션에서 진행)

- **Domain/Presentation 테스트**: `fake_entities.dart` — Entity만 (cloud_firestore 의존 없음)
- **Data 테스트**: `fake_data.dart` (re-export) → `fake_entities.dart` + `fake_models.dart`
- 기존 import `fake_data.dart`는 그대로 유지 (re-export이므로 호환)
- Domain/Presentation 테스트들은 `fake_entities.dart` 직접 import로 변경

---

## TimeSlot startTime/endTime 표현

```
int (분 단위, midnight 기준)
360  = 06:00
1080 = 18:00
1440 = 24:00 (자정)
```

변환:
```dart
final startMinutes = start.hour * 60 + start.minute;
```

---

## Weekday enum (lib/domain/enums/weekday.dart)

```dart
@JsonEnum()
enum Weekday {
  @JsonValue(1) monday,
  @JsonValue(2) tuesday,
  @JsonValue(3) wednesday,
  @JsonValue(4) thursday,
  @JsonValue(5) friday,
  @JsonValue(6) saturday,
  @JsonValue(7) sunday,
  @JsonValue(8) holiday;
}
```

DateTime.weekday (1=월 ~ 7=일)과 일치.

---

## 의존성 흐름 (Phase 2 이후)

```
ReservationUseCase
├─ ReservationRepository (기존)
├─ UserRepository (기존, currentUser)
└─ StoreRepository (신규 추가 — PriceSetting 조회용)
```

---

## 현재 상태

**모든 Phase 완료. 미완료 작업 없음.**

- `dart analyze` 에러 없음
- `flutter test` 66개 전체 통과
- 커밋 필요: 이번 세션 변경 사항 미커밋 상태
