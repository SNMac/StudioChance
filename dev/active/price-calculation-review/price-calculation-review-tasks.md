# 요금 계산 로직 검토 — 태스크

Last Updated: 2026-05-20

## 완료

- [x] `isHeadcountPerPerson` 버그 수정 — `calculatePrice()`에서 플래그 미사용 문제
- [x] `isAllDay` 다일 예약 `isHourly=false` 수정 — 일 수 미반영 문제
- [x] `isAllDay` 다일 예약 DayGroup 수정 — 날짜별 그룹 적용 구조로 재작성
- [x] 슬롯 겹침 감지 로직 검토 (`price_time_input_screen.dart`) — 이상 없음 확인

---

## 완료 (추가)

### 인원별 요금 설정 로직 검토

- [x] `HeadcountInputForm` UI 입력 → `HeadcountRule` 변환 로직 검토 — 이상 없음
- [x] `isHeadcountPerPerson` / `isHeadcountHourly` 토글 동작 확인 — 이상 없음
- [x] `_getFooterDescription` 문구 4가지 조합 정확성 검증 — 이상 없음
- [x] 유효성 검증 (`isValid`) 로직 검토 — `headcountBase=0` 허용은 의도된 동작

### `calculatePrice` 단위 테스트 작성

**파일:** `test/domain/entities/price_setting_test.dart` (20개 테스트, 전체 통과)

#### 시간 지정 예약 기본

- [x] 단일 슬롯 내 예약 — `isHourly=true`
- [x] 단일 슬롯 내 예약 — `isHourly=false`
- [x] 단일 슬롯 내 예약 — `isPerPerson=true`
- [x] 다중 슬롯 경계 걸침 (예: 11:55~16:05 → 3개 슬롯)
- [x] 끝 시간 00:00 자정 처리 (1440 변환)
- [x] DayGroup 미매칭 → 0 반환
- [x] isAllDay 슬롯은 시간 지정 계산 시 skip 확인

#### 인원 추가 요금 (HeadcountRule)

- [x] `isPerPerson=false`, `isHourly=false` → `extraPrice` 단일 추가
- [x] `isPerPerson=true`, `isHourly=false` → `extraPrice × extraPeople`
- [x] `isPerPerson=false`, `isHourly=true` → `(extraPrice × totalHours).round()`
- [x] `isPerPerson=true`, `isHourly=true` → `(extraPrice × extraPeople × totalHours).round()`
- [x] headCount ≤ headcountBase → extraCharge = 0

#### 하루종일 예약

- [x] 단일 하루, `isHourly=true` → `price × 24`
- [x] 단일 하루, `isHourly=false` → `price`
- [x] 단일 하루, `isPerPerson=true` → `price × headCount`
- [x] 다일(2일), `isHourly=true` → `price × 24 × 2`
- [x] 다일(2일), `isHourly=false` → `price × 2`
- [x] 다일, 평일→주말 경계 걸침 → 날짜별 DayGroup 요금 합산
- [x] isAllDay 슬롯 없음 → 0 반환
- [x] 다일, HeadcountRule이 날짜별 그룹에서 적용되는지 확인

---

## 테스트 작성 가이드

### 테스트용 PriceSetting 헬퍼 패턴

```dart
PriceSetting _makeWeekdaySetting({
  required int price,
  bool isHourly = true,
  bool isPerPerson = false,
  int headcountBase = 999, // 기본적으로 추가 요금 없음
  int headcountExtraPrice = 0,
  bool isHeadcountPerPerson = true,
  bool isHeadcountHourly = true,
}) {
  return PriceSetting(dayGroups: [
    DayGroup(
      days: [Weekday.monday, Weekday.tuesday, ...],
      headcountRule: HeadcountRule(
        headcountBase: headcountBase,
        headcountExtraPrice: headcountExtraPrice,
        isHeadcountHourly: isHeadcountHourly,
        isHeadcountPerPerson: isHeadcountPerPerson,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: false,
          startTime: 0,
          endTime: 1440,
          price: price,
          isHourly: isHourly,
          isPerPerson: isPerPerson,
        ),
      ],
    ),
  ]);
}
```

### 평일/주말 분리 DayGroup 헬퍼

```dart
PriceSetting _makeWeekendSplitSetting({
  required int weekdayPrice,
  required int weekendPrice,
}) {
  // 평일 DayGroup + 주말 DayGroup 두 개로 구성
}
```
