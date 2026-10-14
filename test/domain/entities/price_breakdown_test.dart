import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/weekday.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';

const _noExtra = HeadcountRule(
  headcountBase: 999,
  headcountExtraPrice: 0,
  isHeadcountHourly: true,
  isHeadcountPerPerson: true,
);

TimeSlot _hourly(int startHour, int endHour, int price) => TimeSlot(
  isAllDay: false,
  startTime: startHour * 60,
  endTime: endHour * 60,
  price: price,
  isHourly: true,
  isPerPerson: false,
);

PriceSetting _setting(
  List<Weekday> days,
  List<TimeSlot> slots, {
  HeadcountRule rule = _noExtra,
}) => PriceSetting(
  dayGroups: [DayGroup(days: days, headcountRule: rule, timeSlots: slots)],
);

void main() {
  group('breakdownPrice — 시간 지정 예약', () {
    test('슬롯 하나에 걸친 예약은 그 슬롯의 요금 항목 하나로 나온다', () {
      final setting = _setting([Weekday.wednesday], [_hourly(9, 18, 10000)]);

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 14, 10), // 수요일
        end: DateTime(2026, 10, 14, 12),
        headCount: 1,
      );

      expect(breakdown.days, hasLength(1));
      final day = breakdown.days.single;
      expect(day.date, DateTime(2026, 10, 14));
      expect(day.holidayRateApplied, isFalse);
      expect(day.items, [
        const PriceItem.slot(
          startMinute: 600,
          endMinute: 720,
          unitPrice: 10000,
          isHourly: true,
          amount: 20000,
        ),
      ]);
      expect(breakdown.total, 20000);
    });

    test('어느 슬롯에도 걸리지 않는 시간대는 0원 항목으로 시간 순서에 끼워 넣는다', () {
      final setting = _setting(
        [Weekday.wednesday],
        [_hourly(14, 18, 15000), _hourly(9, 12, 10000)],
      );

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 14, 8),
        end: DateTime(2026, 10, 14, 15),
        headCount: 1,
      );

      expect(breakdown.days.single.items, [
        const PriceItem.unpriced(startMinute: 480, endMinute: 540),
        const PriceItem.slot(
          startMinute: 540,
          endMinute: 720,
          unitPrice: 10000,
          isHourly: true,
          amount: 30000,
        ),
        const PriceItem.unpriced(startMinute: 720, endMinute: 840),
        const PriceItem.slot(
          startMinute: 840,
          endMinute: 900,
          unitPrice: 15000,
          isHourly: true,
          amount: 15000,
        ),
      ]);
      expect(breakdown.total, 45000);
    });

    test('1인당 슬롯은 인원 수를, 인원 추가 요금은 빈 시간까지 포함한 예약 시간을 곱한다', () {
      final setting = _setting(
        [Weekday.wednesday],
        [
          const TimeSlot(
            isAllDay: false,
            startTime: 600,
            endTime: 720,
            price: 5000,
            isHourly: true,
            isPerPerson: true,
          ),
        ],
        rule: const HeadcountRule(
          headcountBase: 4,
          headcountExtraPrice: 3000,
          isHeadcountHourly: true,
          isHeadcountPerPerson: true,
        ),
      );

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 14, 10),
        end: DateTime(2026, 10, 14, 13),
        headCount: 6,
      );

      expect(breakdown.days.single.items, [
        const PriceItem.slot(
          startMinute: 600,
          endMinute: 720,
          unitPrice: 5000,
          isHourly: true,
          perPersonCount: 6,
          amount: 60000, // 5,000 × 2시간 × 6명
        ),
        const PriceItem.unpriced(startMinute: 720, endMinute: 780),
        const PriceItem.headcount(
          headcountBase: 4,
          extraPeople: 2,
          unitPrice: 3000,
          isPerPerson: true,
          minutes: 180,
          amount: 18000, // 2명 × 3,000 × 3시간
        ),
      ]);
      expect(breakdown.total, 78000);
    });
  });

  test('시간당 인원 추가 요금은 기존 계산과 같이 단가 × (분/60)을 반올림한다', () {
    // 30원 × 123분: 30 × (123/60) = 61.4999… → 61. 30 × 123 / 60 = 61.5 → 62로 어긋난다
    final setting = _setting(
      [Weekday.wednesday],
      [_hourly(0, 24, 0)],
      rule: const HeadcountRule(
        headcountBase: 1,
        headcountExtraPrice: 30,
        isHeadcountHourly: true,
        isHeadcountPerPerson: false,
      ),
    );

    final breakdown = setting.breakdownPrice(
      start: DateTime(2026, 10, 14, 10),
      end: DateTime(2026, 10, 14, 12, 3),
      headCount: 2,
    );

    expect(breakdown.total, 61);
  });

  group('breakdownPrice — 자정을 넘는 시간 지정 예약', () {
    test('날짜별로 나눠 각 날짜의 요일 그룹으로 계산한다', () {
      final setting = PriceSetting(
        dayGroups: [
          DayGroup(
            days: [Weekday.friday],
            headcountRule: _noExtra,
            timeSlots: [_hourly(18, 24, 10000)],
          ),
          DayGroup(
            days: [Weekday.saturday],
            headcountRule: _noExtra,
            timeSlots: [_hourly(0, 6, 20000)],
          ),
        ],
      );

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 16, 22), // 금요일
        end: DateTime(2026, 10, 17, 2), // 토요일
        headCount: 1,
      );

      expect(breakdown.days, [
        PricedDay(
          date: DateTime(2026, 10, 16),
          holidayRateApplied: false,
          items: const [
            PriceItem.slot(
              startMinute: 1320,
              endMinute: 1440,
              unitPrice: 10000,
              isHourly: true,
              amount: 20000,
            ),
          ],
        ),
        PricedDay(
          date: DateTime(2026, 10, 17),
          holidayRateApplied: false,
          items: const [
            PriceItem.slot(
              startMinute: 0,
              endMinute: 120,
              unitPrice: 20000,
              isHourly: true,
              amount: 40000,
            ),
          ],
        ),
      ]);
      expect(breakdown.total, 60000);
    });

    test('인원 추가 요금은 시간당이면 날짜별 시간만큼, 1회 요금이면 예약당 한 번 받는다', () {
      HeadcountRule rule({required bool hourly}) => HeadcountRule(
        headcountBase: 2,
        headcountExtraPrice: 1000,
        isHeadcountHourly: hourly,
        isHeadcountPerPerson: false,
      );
      PriceSetting settingWith(HeadcountRule r) => _setting(
        [Weekday.friday, Weekday.saturday],
        [_hourly(0, 24, 10000)],
        rule: r,
      );
      List<int?> headcountMinutes(PriceBreakdown b) => [
        for (final day in b.days)
          for (final item in day.items)
            if (item is HeadcountCharge) item.minutes ?? -1,
      ];

      final hourly = settingWith(rule(hourly: true)).breakdownPrice(
        start: DateTime(2026, 10, 16, 23), // 금 23:00
        end: DateTime(2026, 10, 17, 2), // 토 02:00
        headCount: 3,
      );
      final oneTime = settingWith(rule(hourly: false)).breakdownPrice(
        start: DateTime(2026, 10, 16, 23),
        end: DateTime(2026, 10, 17, 2),
        headCount: 3,
      );

      expect(headcountMinutes(hourly), [60, 120]);
      expect(hourly.total, 30000 + 1000 + 2000);
      expect(headcountMinutes(oneTime), [-1]); // 금요일에 1회
      expect(oneTime.total, 30000 + 1000);
    });
  });

  group('breakdownPrice — 하루종일 예약', () {
    test('날짜마다 하루종일 요금과 인원 추가 요금을 받고, 요금 설정이 없는 날짜는 하루 전체가 0원이다', () {
      final setting = _setting(
        [Weekday.friday, Weekday.saturday],
        [
          const TimeSlot(
            isAllDay: true,
            startTime: 0,
            endTime: 1440,
            price: 180000,
            isHourly: false,
            isPerPerson: false,
          ),
        ],
        rule: const HeadcountRule(
          headcountBase: 6,
          headcountExtraPrice: 10000,
          isHeadcountHourly: false,
          isHeadcountPerPerson: true,
        ),
      );

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 8), // 목요일 — 요일 그룹 없음
        end: DateTime(2026, 10, 10), // 2일: 10/8(목), 10/9(금)
        headCount: 8,
        isAllDay: true,
      );

      const headcount = PriceItem.headcount(
        headcountBase: 6,
        extraPeople: 2,
        unitPrice: 10000,
        isPerPerson: true,
        amount: 20000,
      );
      expect(breakdown.days, [
        PricedDay(
          date: DateTime(2026, 10, 8),
          holidayRateApplied: false,
          items: const [PriceItem.unpriced(startMinute: 0, endMinute: 1440)],
        ),
        PricedDay(
          date: DateTime(2026, 10, 9),
          holidayRateApplied: false,
          items: const [
            PriceItem.slot(
              startMinute: 0,
              endMinute: 1440,
              unitPrice: 180000,
              isHourly: false,
              amount: 180000,
            ),
            headcount,
          ],
        ),
      ]);
      expect(breakdown.total, 200000);
    });
  });

  group('breakdownPrice — 공휴일 요금 적용 여부', () {
    final allDay = const TimeSlot(
      isAllDay: true,
      startTime: 0,
      endTime: 1440,
      price: 100000,
      isHourly: false,
      isPerPerson: false,
    );

    test('공휴일 요일 그룹으로 계산한 날짜만 공휴일 요금 적용으로 표시한다', () {
      final setting = PriceSetting(
        dayGroups: [
          DayGroup(
            days: [Weekday.thursday, Weekday.friday],
            headcountRule: _noExtra,
            timeSlots: [allDay],
          ),
          DayGroup(
            days: [Weekday.holiday],
            headcountRule: _noExtra,
            timeSlots: [allDay.copyWith(price: 200000)],
          ),
        ],
      );

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 8), // 목요일
        end: DateTime(2026, 10, 10), // 10/8(목), 10/9(금, 한글날)
        headCount: 1,
        isAllDay: true,
        isHoliday: (date) => date.day == 9,
      );

      expect(breakdown.days.map((d) => d.holidayRateApplied), [false, true]);
      expect(breakdown.total, 300000);
    });

    test('공휴일 요일 그룹이 없으면 공휴일이어도 공휴일 요금 적용이 아니다', () {
      final setting = _setting([Weekday.friday], [allDay]);

      final breakdown = setting.breakdownPrice(
        start: DateTime(2026, 10, 9), // 금요일, 한글날
        end: DateTime(2026, 10, 10),
        headCount: 1,
        isAllDay: true,
        isHoliday: (_) => true,
      );

      expect(breakdown.days.single.holidayRateApplied, isFalse);
      expect(breakdown.total, 100000);
    });
  });
}
