# Use Case 개선 — 플랜

Last Updated: 2026-04-20

## Executive Summary

Domain Use Case 레이어의 미연결 stub 2건을 수정하고,
예약 가격 자동 계산 로직을 도메인 레이어에 추가한다.

총 2가지 범주로 구분:
- **Phase 1** (완료): Use Case stub 연결
- **Phase 2** (진행 예정): PriceSetting 가격 계산 도메인 로직 추가

---

## Current State Analysis

### Phase 1 이전 문제 (완료됨)

#### [STUB-1] `UserUseCaseImpl.updateStoreInfo` — 항상 에러 반환
- **위치**: `lib/domain/use_cases/user_use_case.dart`
- **현상**: `Future.value(left(Exception('UserRepository 업데이트 필요')))` 반환
- **원인**: Repository 인터페이스와 구현체가 이미 준비되어 있었으나 UseCase에서 연결되지 않음
- **수정**: `_repository.updateStoreInfo(...)` 직접 위임으로 변경 ✅

#### [STUB-2] `StoreUseCaseImpl.updateMemberRole` — 항상 에러 반환
- **위치**: `lib/domain/use_cases/store_use_case.dart`
- **현상**: `TaskEither.left(Exception('기능 구현 예정')).run()` 반환
- **원인**: `StoreRepository.updateMemberRole` 인터페이스와 구현체가 모두 존재했으나 UseCase 연결 누락
- **수정**: `_storeRepository.updateMemberRole(...)` 위임으로 변경 ✅

### Phase 2 배경 — 가격 자동 계산

`Reservation` 엔티티에는 3개의 가격 필드가 존재한다:
- `calculatedPrice`: PriceSetting + 시간 + 인원 기반 자동 계산값
- `priceAdjustment`: 사용자가 입력한 조정값 (할인 시 음수)
- `totalPrice`: `calculatedPrice + priceAdjustment`

현재 상태:
- `calculatedPrice`는 UI에서 사용자가 수동 입력 (`_priceController.text`)
- `PriceSetting` 기반 자동 계산 로직이 **어디에도 없음**
- UseCase가 Store의 PriceSetting을 조회하지 않고 reservation을 그대로 저장

---

## PriceSetting 계산 로직 설계

### 데이터 구조

```
PriceSetting
└─ List<DayGroup>
   ├─ days: List<Weekday>           // 적용 요일 (1=월 ~ 7=일, 8=공휴일)
   ├─ headcountRule: HeadcountRule  // 인원 추가 요금 규칙
   │  ├─ headcountBase: int         // 기본 포함 인원
   │  ├─ headcountExtraPrice: int   // 기본 초과 시 1인당 추가 요금
   │  ├─ isHeadcountHourly: bool    // 추가 요금이 시간당인지 여부
   │  └─ isHeadcountPerPerson: bool // (isHeadcountHourly와 조합으로 해석)
   └─ timeSlots: List<TimeSlot>    // 시간대별 요금
      ├─ isAllDay: bool             // 하루종일 슬롯 여부
      ├─ startTime: int             // 시작 시각 (분 단위, 360 = 06:00)
      ├─ endTime: int               // 종료 시각 (분 단위, 1080 = 18:00)
      ├─ price: int                 // 기본 요금
      ├─ isHourly: bool             // 시간당 요금 여부
      └─ isPerPerson: bool          // 1인당 요금 여부
```

### 계산 알고리즘

```
calculatePrice(start: DateTime, end: DateTime, headCount: int) → int

1. 예약 요일 → 해당 DayGroup 탐색
   - start.weekday (1=월 ~ 7=일)을 Weekday enum으로 변환
   - days에 해당 요일을 포함하는 DayGroup 선택
   - 없으면 0 반환

2. isAllDay 예약 처리
   - isAllDay=true인 예약이면 DayGroup의 isAllDay=true 슬롯 선택
   - 없으면 0 반환

3. 시간대별 TimeSlot 탐색
   - start의 분(minutes from midnight)이 슬롯 범위 내에 있는 슬롯 선택
   - startMinutes = start.hour * 60 + start.minute

4. 기본 요금 계산
   - hours = (end - start).inMinutes / 60.0 (반올림 없이 실수)
   - basePrice = slot.isHourly
       ? (slot.price * hours).round()
       : slot.price
   - if slot.isPerPerson: basePrice *= headCount

5. 인원 추가 요금 계산
   - extraPeople = max(0, headCount - rule.headcountBase)
   - if extraPeople > 0:
       - extraCharge = rule.headcountExtraPrice * extraPeople
       - if rule.isHeadcountHourly: extraCharge = (extraCharge * hours).round()
   - else: extraCharge = 0

6. return basePrice + extraCharge
```

### PriceSetting에 추가할 메서드

```dart
// lib/domain/entities/price_setting.dart

const PriceSetting._();

/// 예약 시간과 인원 기반 기본 요금 계산
/// PriceSetting에 맞는 DayGroup/TimeSlot이 없으면 0 반환
int calculatePrice({
  required DateTime start,
  required DateTime end,
  required int headCount,
  bool isAllDay = false,
}) { ... }
```

---

## Implementation Phases

### Phase 1 — Use Case stub 연결 ✅ (완료)

파일: `user_use_case.dart`, `store_use_case.dart`

### Phase 2 — PriceSetting 가격 계산 도메인 로직

**2-1. `PriceSetting` 엔티티에 계산 메서드 추가**

파일: `lib/domain/entities/price_setting.dart`
- `const PriceSetting._()` private constructor 추가 (Freezed custom method용)
- `calculatePrice({required DateTime start, required DateTime end, required int headCount, bool isAllDay = false})` 메서드 구현
- 의존: `DayGroup`, `TimeSlot`, `HeadcountRule`, `Weekday` enum

**2-2. `ReservationUseCase.createReservation` 가격 자동 계산**

파일: `lib/domain/use_cases/reservation_use_case.dart`
- `StoreRepository` 의존성 추가
- `createReservation` 내에서 Store 조회 → `priceSetting.calculatePrice(...)` 호출
- `calculatedPrice`, `totalPrice` 자동 설정 후 저장

**2-3. `ReservationUseCase.updateReservation` 가격 재계산**

파일: `lib/domain/use_cases/reservation_use_case.dart`
- `updateReservation` 내에서 시간/인원 변경 시 재계산
- Store 조회 후 `calculatedPrice` 갱신, `totalPrice = calculatedPrice + priceAdjustment`

---

## Risk Assessment

| 항목 | 위험도 | 비고 |
|------|--------|------|
| PriceSetting 메서드 추가 | 낮음 | Freezed custom method, 기존 필드 변경 없음 |
| UseCase에 StoreRepository 추가 | 낮음 | Provider 의존성 추가만 필요 |
| 기존 수동 입력 가격 호환 | 낮음 | UI는 calculatedPrice를 초기값으로만 사용, 사용자 편집 유지 |
| DayGroup/TimeSlot 매칭 실패 | 낮음 | 매칭 실패 시 0 반환하여 사용자 수동 입력 유도 |

---

## Success Metrics

- [ ] `PriceSetting.calculatePrice()` 순수 함수로 동작 (외부 의존 없음)
- [ ] `createReservation` 시 Store PriceSetting 기반 `calculatedPrice` 자동 설정
- [ ] `updateReservation` 시 시간/인원 변경 반영하여 `calculatedPrice` 재계산
- [ ] 코드 생성 오류 없음 (`dart run build_runner build`)
