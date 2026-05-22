# 요금 계산 로직 검토 — 컨텍스트

Last Updated: 2026-05-20

## 핵심 구조

### PriceSetting.calculatePrice() 파라미터

```dart
int calculatePrice({
  required DateTime start,
  required DateTime end,
  required int headCount,
  bool isAllDay = false,
  bool isHoliday = false, // 항상 false (공휴일 API 미구현, holiday-pricing 태스크 참고)
})
```

### DayGroup 구조

```
DayGroup
├── days: List<Weekday>         — 이 그룹에 속하는 요일
├── headcountRule: HeadcountRule — 인원 추가 요금 규칙
└── timeSlots: List<TimeSlot>   — 시간대별 요금 슬롯
```

### TimeSlot 플래그

| 필드 | 의미 |
|---|---|
| `isAllDay` | true = 00:00~24:00 전일 슬롯 |
| `isHourly` | true = 시간당 요금 / false = 고정 요금 |
| `isPerPerson` | true = 인원당 부과 / false = 총액 기준 |

### HeadcountRule 플래그

| 필드 | 의미 |
|---|---|
| `headcountBase` | 기본 요금 적용 인원 수 (이하는 추가 없음) |
| `headcountExtraPrice` | 초과 인원당(또는 고정) 추가 요금 |
| `isHeadcountPerPerson` | true = extraPeople만큼 곱 / false = 고정 단일 추가 |
| `isHeadcountHourly` | true = totalHours 곱 / false = 고정 |

### 계산 흐름 요약

```
isAllDay=true
  └── 날짜별 순회 (numberOfDays)
        ├── dayDate의 요일 → DayGroup 탐색
        ├── isAllDay 슬롯 탐색
        ├── dayBase = isHourly ? price×24 : price
        ├── isPerPerson ? dayBase×headCount
        └── dayExtra = headcountRule 적용 (24h 기준)

isAllDay=false
  └── start 요일 → DayGroup 탐색
        ├── 각 슬롯과 예약 구간 겹침 계산 (분 단위)
        ├── slotPrice = isHourly ? price×overlapHours : price
        ├── isPerPerson ? slotPrice×headCount
        └── extraCharge = headcountRule 적용 (totalHours 기준)
```

---

## 관련 설계 결정

### D6 — 공휴일 요금 isHoliday 파라미터 패턴

`calculatePrice(isHoliday: bool)`로 공휴일 판단을 호출부에 위임.
현재 모든 호출부(`_applyCalculatedPrice`, 두 예약 모달)는 `isHoliday: false` 고정.
→ `dev/active/holiday-pricing/` 참고

### 수정된 버그 (2026-05-20)

1. **`isHeadcountPerPerson` 미사용** — 항상 per-person으로 계산되던 문제 수정
2. **`isAllDay` 다일 `isHourly=false`** — 일 수 반영 안 되던 문제 수정
3. **`isAllDay` 다일 DayGroup** — 시작일 기준으로만 적용되던 문제 수정

---

## 주요 파일 경로

| 파일 | 비고 |
|---|---|
| `lib/domain/entities/price_setting.dart` | `calculatePrice()` 핵심 로직 |
| `lib/domain/entities/day_group.dart` | DayGroup 엔티티 |
| `lib/domain/entities/time_slot.dart` | TimeSlot 엔티티 |
| `lib/domain/entities/headcount_rule.dart` | HeadcountRule 엔티티 |
| `lib/domain/enums/weekday.dart` | Weekday enum (holiday=JsonValue 8) |
| `lib/presentation/commons/store_input/widgets/headcount_input_form.dart` | 인원별 요금 입력 UI |
| `lib/presentation/commons/store_input/screens/price_time_input_screen.dart` | 슬롯 겹침 감지 포함 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | `_recalculatePrice` 호출 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | `_recalculatePrice` 호출 |
| `lib/domain/use_cases/reservation_use_case.dart` | `_applyCalculatedPrice` 호출 |
| `test/helpers/fake_entities.dart` | 테스트 헬퍼 |
