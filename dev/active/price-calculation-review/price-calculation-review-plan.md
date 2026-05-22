# 요금 계산 로직 검토 및 테스트 작성

Last Updated: 2026-05-20

## 개요

`PriceSetting.calculatePrice()` 메서드의 버그 수정 및 로직 검증, 그리고 인원별 요금
설정 로직 검토와 단위 테스트 작성을 목표로 한다.

---

## 완료된 작업

### 1. `isHeadcountPerPerson` 버그 수정

**문제:** `HeadcountRule.isHeadcountPerPerson` 필드가 선언되어 있었으나
`calculatePrice()`에서 전혀 읽히지 않아, `false`로 설정해도 항상 인원당 요금으로
계산되었다.

**수정 전:**
```dart
extraCharge = rule.headcountExtraPrice * extraPeople; // isHeadcountPerPerson 무시
```

**수정 후:**
```dart
extraCharge = rule.headcountExtraPrice;
if (rule.isHeadcountPerPerson) extraCharge *= extraPeople;
if (rule.isHeadcountHourly) extraCharge = (extraCharge * totalHours).round();
```

**4가지 조합 동작:**

| `isHeadcountPerPerson` | `isHeadcountHourly` | 계산 결과 |
|---|---|---|
| false | false | `extraPrice` (고정 단일 추가) |
| true | false | `extraPrice × extraPeople` |
| false | true | `(extraPrice × totalHours).round()` |
| true | true | `(extraPrice × extraPeople × totalHours).round()` |

---

### 2. `isAllDay` 다일 예약 버그 수정

**문제 1 — `isHourly=false` 다일 예약 시 일 수 미반영:**
1일이든 3일이든 동일한 `slot.price`가 반환되었다.

**문제 2 — 다일 예약 시 DayGroup이 시작일 기준으로만 적용:**
금요일 시작 ~ 일요일 종료 예약이라도 금요일(평일) 요금만 적용되어,
주말 DayGroup이 반영되지 않았다.

**수정:** `isAllDay` 분기를 "날짜별 순회" 구조로 재작성.

```dart
if (isAllDay) {
  final numberOfDays = end.difference(start).inDays;
  for (int dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
    final dayDate = start.add(Duration(days: dayOffset));
    // 날짜별 요일 → 해당 DayGroup → isAllDay 슬롯 → 요금 합산
  }
}
```

**수정 후 동작:**

| 케이스 | 동작 |
|---|---|
| 단일 하루, `isHourly=true` | `(price × 24).round()` |
| 단일 하루, `isHourly=false` | `price` |
| 다일, `isHourly=true` | `(price × 24).round() × 일수` |
| 다일, `isHourly=false` | `price × 일수` |
| 다일, 요일 그룹 경계 걸침 | 날짜별 해당 그룹 적용 후 합산 |

HeadcountRule도 날짜별 DayGroup에서 가져오므로, 평일/주말 인원 추가 요금이
다른 경우도 정확히 반영된다.

---

### 3. 겹침 감지 로직 검토 (이상 없음)

`price_time_input_screen.dart`의 슬롯 겹침 감지 로직은 `isAllDay=true` 슬롯을
0~1440으로 처리하여 모든 슬롯과의 겹침을 올바르게 검출한다. 수정 불필요.

---

## 진행 중인 작업

### 4. 인원별 요금 설정 로직 검토

**대상:** `HeadcountInputForm` (`lib/presentation/commons/store_input/widgets/headcount_input_form.dart`)
및 `HeadcountRule` 엔티티

**검토 항목:**
- UI 입력값이 `HeadcountRule`에 올바르게 반영되는지
- `isHeadcountPerPerson` / `isHeadcountHourly` 토글이 정상 동작하는지
- footer 설명 문구(`_getFooterDescription`)가 4가지 조합에 대해 정확한지
- 유효성 검증 로직이 충분한지 (기준 인원 0 허용 여부 등)

**`_getFooterDescription` 현재 문구:**

| `isHourly` | `isPerPerson` | 문구 |
|---|---|---|
| true | true | 초과 인원수만큼 추가 요금이 1시간마다 부과됩니다 |
| true | false | 추가 요금이 1시간마다 부과됩니다 |
| false | true | 초과 인원수만큼 추가 요금이 한 번만 부과됩니다 |
| false | false | 초과 인원수와 관계없이 추가 요금이 한 번만 부과됩니다 |

---

### 5. `calculatePrice` 단위 테스트 작성

**테스트 파일 위치:** `test/domain/entities/price_setting_test.dart`

**커버해야 할 케이스:**

#### 시간 지정 예약
- 단일 슬롯 완전 포함 (예약이 슬롯 범위 내)
- 다중 슬롯 경계 걸침 (11:55~16:05 → 3개 슬롯)
- DayGroup 미매칭 → 0 반환
- isAllDay 슬롯 skip 확인

#### 플래그 조합
- `isHourly=true` / `isHourly=false`
- `isPerPerson=true` / `isPerPerson=false`
- 끝 시간 00:00(자정, 1440 처리) 경계 케이스

#### 인원 추가 요금 (4가지 조합)
- `isHeadcountPerPerson=false`, `isHeadcountHourly=false`
- `isHeadcountPerPerson=true`, `isHeadcountHourly=false`
- `isHeadcountPerPerson=false`, `isHeadcountHourly=true`
- `isHeadcountPerPerson=true`, `isHeadcountHourly=true`
- headCount ≤ headcountBase → extraCharge=0

#### 하루종일 예약
- 단일 하루, `isHourly=true` → price × 24
- 단일 하루, `isHourly=false` → price
- 다일(2일), `isHourly=true` → price × 24 × 2
- 다일(2일), `isHourly=false` → price × 2
- 다일, 평일→주말 경계 걸침 → 각 날짜 DayGroup 적용
- isAllDay 슬롯 없음 → 0 반환

---

## 관련 파일

| 파일 | 역할 |
|---|---|
| `lib/domain/entities/price_setting.dart` | 핵심 계산 로직 |
| `lib/domain/entities/day_group.dart` | DayGroup 엔티티 |
| `lib/domain/entities/time_slot.dart` | TimeSlot 엔티티 |
| `lib/domain/entities/headcount_rule.dart` | HeadcountRule 엔티티 |
| `lib/presentation/commons/store_input/widgets/headcount_input_form.dart` | 인원별 요금 입력 UI |
| `lib/presentation/commons/store_input/screens/price_time_input_screen.dart` | 시간별 요금 입력 + 겹침 감지 |
| `test/domain/entities/price_setting_test.dart` | 신규 테스트 파일 (작성 예정) |
| `test/helpers/fake_entities.dart` | 테스트용 fake 엔티티 |
