# Use Case 개선 — 컨텍스트

Last Updated: 2026-04-20

---

## 핵심 파일

### Domain — Use Cases (수정 대상)
| 파일 | 역할 | 수정 사항 |
|------|------|----------|
| `lib/domain/use_cases/user_use_case.dart` | 사용자 비즈니스 로직 | [STUB-1] 완료 |
| `lib/domain/use_cases/store_use_case.dart` | 점포 비즈니스 로직 | [STUB-2] 완료 |
| `lib/domain/use_cases/reservation_use_case.dart` | 예약 비즈니스 로직 | Phase 2 수정 예정 |

### Domain — Entities (수정 대상)
| 파일 | 역할 | 수정 사항 |
|------|------|----------|
| `lib/domain/entities/price_setting.dart` | 가격 설정 집합 | Phase 2-1: calculatePrice 추가 |
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
