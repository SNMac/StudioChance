import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/common/enums/weekday.dart';

// 평일(월~금) 단일 DayGroup 설정 — 시간 지정 예약 테스트용
PriceSetting _makeWeekdaySetting({
  required int price,
  bool isHourly = true,
  bool isPerPerson = false,
  bool isAllDay = false,
  int startTime = 0,
  int endTime = 1440,
  int headcountBase = 999,
  int headcountExtraPrice = 0,
  bool isHeadcountPerPerson = true,
  bool isHeadcountHourly = true,
}) {
  return PriceSetting(dayGroups: [
    DayGroup(
      days: [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      ],
      headcountRule: HeadcountRule(
        headcountBase: headcountBase,
        headcountExtraPrice: headcountExtraPrice,
        isHeadcountHourly: isHeadcountHourly,
        isHeadcountPerPerson: isHeadcountPerPerson,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime,
          price: price,
          isHourly: isHourly,
          isPerPerson: isPerPerson,
        ),
      ],
    ),
  ]);
}

// 평일 DayGroup + 주말 DayGroup — isAllDay 다일 경계 테스트용
PriceSetting _makeWeekendSplitSetting({
  required int weekdayPrice,
  required int weekendPrice,
  bool isHourly = false,
  int weekdayHeadcountBase = 999,
  int weekdayHeadcountExtraPrice = 0,
  int weekendHeadcountBase = 999,
  int weekendHeadcountExtraPrice = 0,
  bool isHeadcountPerPerson = true,
  bool isHeadcountHourly = false,
}) {
  return PriceSetting(dayGroups: [
    DayGroup(
      days: [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      ],
      headcountRule: HeadcountRule(
        headcountBase: weekdayHeadcountBase,
        headcountExtraPrice: weekdayHeadcountExtraPrice,
        isHeadcountHourly: isHeadcountHourly,
        isHeadcountPerPerson: isHeadcountPerPerson,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: true,
          startTime: 0,
          endTime: 1440,
          price: weekdayPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
    DayGroup(
      days: [Weekday.saturday, Weekday.sunday],
      headcountRule: HeadcountRule(
        headcountBase: weekendHeadcountBase,
        headcountExtraPrice: weekendHeadcountExtraPrice,
        isHeadcountHourly: isHeadcountHourly,
        isHeadcountPerPerson: isHeadcountPerPerson,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: true,
          startTime: 0,
          endTime: 1440,
          price: weekendPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
  ]);
}

// 평일 DayGroup + Weekday.holiday DayGroup — isHoliday 콜백 테스트용
PriceSetting _makeHolidaySplitSetting({
  required int weekdayPrice,
  required int holidayPrice,
  bool isAllDay = false,
  bool isHourly = false,
  int startTime = 0,
  int endTime = 1440,
}) {
  return PriceSetting(dayGroups: [
    DayGroup(
      days: [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      ],
      headcountRule: HeadcountRule(
        headcountBase: 999,
        headcountExtraPrice: 0,
        isHeadcountHourly: false,
        isHeadcountPerPerson: false,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime,
          price: weekdayPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
    DayGroup(
      days: [Weekday.holiday],
      headcountRule: HeadcountRule(
        headcountBase: 999,
        headcountExtraPrice: 0,
        isHeadcountHourly: false,
        isHeadcountPerPerson: false,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime,
          price: holidayPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
  ]);
}

void main() {
  // 기준 날짜: 2026-05-18 월요일(weekday=1), 2026-05-15 금요일(weekday=5),
  //           2026-05-16 토요일(weekday=6), 2026-05-17 일요일(weekday=7)

  group('calculatePrice — 시간 지정 예약 기본', () {
    test('단일 슬롯 내 예약 — isHourly=true', () {
      final setting = _makeWeekdaySetting(price: 10000, isHourly: true);
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0), // 월요일
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
      );
      expect(result, 20000); // 10,000 × 2h
    });

    test('단일 슬롯 내 예약 — isHourly=false (고정 요금)', () {
      final setting = _makeWeekdaySetting(price: 50000, isHourly: false);
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 14, 0),
        headCount: 1,
      );
      expect(result, 50000);
    });

    test('단일 슬롯 내 예약 — isPerPerson=true', () {
      final setting =
          _makeWeekdaySetting(price: 5000, isHourly: true, isPerPerson: true);
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 11, 0),
        headCount: 3,
      );
      expect(result, 15000); // 5,000 × 1h × 3명
    });

    test('다중 슬롯 경계 걸침 — 11:55~16:05', () {
      // 슬롯 A: 10:00(600)~14:00(840) @ 8,000/h
      // 슬롯 B: 14:00(840)~18:00(1080) @ 12,000/h
      final setting = PriceSetting(dayGroups: [
        DayGroup(
          days: [Weekday.monday],
          headcountRule: HeadcountRule(
            headcountBase: 999,
            headcountExtraPrice: 0,
            isHeadcountHourly: true,
            isHeadcountPerPerson: true,
          ),
          timeSlots: [
            TimeSlot(
              isAllDay: false,
              startTime: 600,
              endTime: 840,
              price: 8000,
              isHourly: true,
              isPerPerson: false,
            ),
            TimeSlot(
              isAllDay: false,
              startTime: 840,
              endTime: 1080,
              price: 12000,
              isHourly: true,
              isPerPerson: false,
            ),
          ],
        ),
      ]);
      // 슬롯 A 겹침: 715~840 = 125min → (8000 × 125/60).round() = 16667
      // 슬롯 B 겹침: 840~965 = 125min → (12000 × 125/60).round() = 25000
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 11, 55),
        end: DateTime(2026, 5, 18, 16, 5),
        headCount: 1,
      );
      expect(result, 16667 + 25000); // 41667
    });

    test('끝 시간 00:00 자정 — 1440분으로 처리', () {
      // 22:00~00:00(자정): 2시간
      final setting = _makeWeekdaySetting(price: 10000, isHourly: true);
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 22, 0),
        end: DateTime(2026, 5, 19, 0, 0), // rawEnd=0 → 1440
        headCount: 1,
      );
      expect(result, 20000); // 10,000 × 2h
    });

    test('DayGroup 미매칭 → 0 반환', () {
      // 평일 설정에서 토요일 예약
      final setting = _makeWeekdaySetting(price: 10000, isHourly: true);
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 16, 10, 0), // 토요일
        end: DateTime(2026, 5, 16, 12, 0),
        headCount: 1,
      );
      expect(result, 0);
    });

    test('isAllDay 슬롯은 시간 지정 계산 시 skip', () {
      // isAllDay=true 슬롯만 있는 설정 → isAllDay=false 예약 시 매칭 없음
      final setting = _makeWeekdaySetting(
        price: 100000,
        isHourly: false,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
        isAllDay: false,
      );
      expect(result, 0);
    });
  });

  group('calculatePrice — 인원 추가 요금 (HeadcountRule)', () {
    test('isPerPerson=false, isHourly=false → extraPrice 단일 추가', () {
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: false,
        headcountBase: 2,
        headcountExtraPrice: 5000,
        isHeadcountPerPerson: false,
        isHeadcountHourly: false,
      );
      // 3명 → extraPeople=1, extraCharge=5000 (고정)
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 3,
      );
      expect(result, 15000); // 10,000 + 5,000
    });

    test('isPerPerson=true, isHourly=false → extraPrice × extraPeople', () {
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: false,
        headcountBase: 2,
        headcountExtraPrice: 3000,
        isHeadcountPerPerson: true,
        isHeadcountHourly: false,
      );
      // 5명 → extraPeople=3, extraCharge=3,000×3=9,000
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 5,
      );
      expect(result, 19000); // 10,000 + 9,000
    });

    test('isPerPerson=false, isHourly=true → (extraPrice × totalHours).round()',
        () {
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: true,
        headcountBase: 2,
        headcountExtraPrice: 2000,
        isHeadcountPerPerson: false,
        isHeadcountHourly: true,
      );
      // 3명, 3시간 → extraPeople=1, extraCharge=(2,000×3).round()=6,000
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 13, 0),
        headCount: 3,
      );
      expect(result, 36000); // 30,000 + 6,000
    });

    test(
        'isPerPerson=true, isHourly=true → (extraPrice × extraPeople × totalHours).round()',
        () {
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: true,
        headcountBase: 2,
        headcountExtraPrice: 1000,
        isHeadcountPerPerson: true,
        isHeadcountHourly: true,
      );
      // 4명, 2시간 → extraPeople=2, extraCharge=(1,000×2×2).round()=4,000
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 4,
      );
      expect(result, 24000); // 20,000 + 4,000
    });

    test('headCount ≤ headcountBase → extraCharge = 0', () {
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: true,
        headcountBase: 5,
        headcountExtraPrice: 2000,
        isHeadcountPerPerson: true,
        isHeadcountHourly: true,
      );
      // 3명 (≤ 기준 5명) → extraPeople=0, extraCharge=0
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0),
        end: DateTime(2026, 5, 18, 11, 0),
        headCount: 3,
      );
      expect(result, 10000); // 추가 요금 없음
    });
  });

  group('calculatePrice — 하루종일 예약', () {
    test('단일 하루, isHourly=true → price × 24', () {
      final setting = _makeWeekdaySetting(
        price: 5000,
        isHourly: true,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18),
        end: DateTime(2026, 5, 19),
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 120000); // 5,000 × 24
    });

    test('단일 하루, isHourly=false → price', () {
      final setting = _makeWeekdaySetting(
        price: 100000,
        isHourly: false,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18),
        end: DateTime(2026, 5, 19),
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 100000);
    });

    test('단일 하루, isPerPerson=true → price × headCount', () {
      final setting = _makeWeekdaySetting(
        price: 20000,
        isHourly: false,
        isPerPerson: true,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18),
        end: DateTime(2026, 5, 19),
        headCount: 4,
        isAllDay: true,
      );
      expect(result, 80000); // 20,000 × 4명
    });

    test('다일(2일), isHourly=true → price × 24 × 2', () {
      final setting = _makeWeekdaySetting(
        price: 5000,
        isHourly: true,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18), // 월요일
        end: DateTime(2026, 5, 20), // 수요일 (2일: 월, 화)
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 240000); // 5,000 × 24 × 2
    });

    test('다일(2일), isHourly=false → price × 2', () {
      final setting = _makeWeekdaySetting(
        price: 100000,
        isHourly: false,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18), // 월요일
        end: DateTime(2026, 5, 20), // 수요일 (2일)
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 200000); // 100,000 × 2
    });

    test('다일, 평일→주말 경계 걸침 → 날짜별 DayGroup 요금 합산', () {
      // 금 50,000원 / 토 80,000원 (isHourly=false)
      final setting = _makeWeekendSplitSetting(
        weekdayPrice: 50000,
        weekendPrice: 80000,
        isHourly: false,
      );
      // 2026-05-15(금) ~ 2026-05-17(일): 금, 토 2일
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 15),
        end: DateTime(2026, 5, 17),
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 130000); // 50,000 + 80,000
    });

    test('isAllDay 슬롯 없음 → 0 반환', () {
      // isAllDay=false 슬롯만 있는 설정에서 isAllDay=true 예약
      final setting = _makeWeekdaySetting(
        price: 10000,
        isHourly: true,
        isAllDay: false,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18),
        end: DateTime(2026, 5, 19),
        headCount: 1,
        isAllDay: true,
      );
      expect(result, 0);
    });

    test('다일, HeadcountRule이 날짜별 DayGroup에서 각각 적용됨', () {
      // 평일: 50,000원 + 추가 1,000원/인, 주말: 80,000원 + 추가 2,000원/인
      // (isHeadcountHourly=false, isHeadcountPerPerson=true, headcountBase=2)
      final setting = _makeWeekendSplitSetting(
        weekdayPrice: 50000,
        weekendPrice: 80000,
        isHourly: false,
        weekdayHeadcountBase: 2,
        weekdayHeadcountExtraPrice: 1000,
        weekendHeadcountBase: 2,
        weekendHeadcountExtraPrice: 2000,
        isHeadcountPerPerson: true,
        isHeadcountHourly: false,
      );
      // 3명 → extraPeople=1
      // 금: 50,000 + 1,000×1 = 51,000
      // 토: 80,000 + 2,000×1 = 82,000
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 15), // 금요일
        end: DateTime(2026, 5, 17), // 2일: 금, 토
        headCount: 3,
        isAllDay: true,
      );
      expect(result, 133000); // 51,000 + 82,000
    });
  });

  group('calculatePrice — isHoliday 콜백', () {
    test('isHoliday 콜백이 true를 반환하면 Weekday.holiday DayGroup을 사용한다', () {
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 10000,
        holidayPrice: 30000,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0), // 월요일
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
        isHoliday: (date) => true,
      );
      expect(result, 30000);
    });

    test('isHoliday를 생략하면 모든 날짜가 공휴일이 아닌 것으로 처리된다', () {
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 10000,
        holidayPrice: 30000,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0), // 월요일
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
      );
      expect(result, 10000);
    });

    test('다일 예약에서 isHoliday 콜백이 날짜별로 다르게 적용된다 (C-1 회귀 테스트)', () {
      // 이전 버그: 단일 bool이 모든 날짜에 일괄 적용되어 날짜별로 다른
      // 결과(평일 50,000 + 공휴일 90,000 = 140,000)를 만들 수 없었음
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 50000,
        holidayPrice: 90000,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18), // 월요일
        end: DateTime(2026, 5, 20), // 2일: 5/18(월), 5/19(화)
        headCount: 1,
        isAllDay: true,
        isHoliday: (date) => date.day == 19, // 5/19(화)만 공휴일로 지정
      );
      expect(result, 140000); // 월 50,000(평일) + 화 90,000(공휴일)
    });
  });
}
