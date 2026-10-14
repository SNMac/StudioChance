import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/common/enums/weekday.dart';

part 'price_setting.freezed.dart';

/// [PriceSetting.calculatePrice]가 요일(공휴일 여부)을 판단하는 날짜들.
///
/// 하루종일 예약은 예약 기간의 각 날짜, 시간 지정 예약은 시작 날짜 하나다.
/// 공휴일 스냅샷도 이 날짜들만 다뤄야 계산과 어긋나지 않는다.
List<DateTime> pricedDatesOf({
  required DateTime start,
  required DateTime end,
  required bool isAllDay,
}) {
  final startDate = DateTime(start.year, start.month, start.day);
  if (!isAllDay) return [startDate];
  return [
    for (
      int dayOffset = 0;
      dayOffset < end.difference(start).inDays;
      dayOffset++
    )
      startDate.add(Duration(days: dayOffset)),
  ];
}

/// [pricedDatesOf]의 연도들 — 가격 계산에 필요한 공휴일 달력 범위.
Set<int> pricedYearsOf({
  required DateTime start,
  required DateTime end,
  required bool isAllDay,
}) => pricedDatesOf(
  start: start,
  end: end,
  isAllDay: isAllDay,
).map((date) => date.year).toSet();

@freezed
abstract class PriceSetting with _$PriceSetting {
  const PriceSetting._();

  const factory PriceSetting({required List<DayGroup> dayGroups}) =
      _PriceSetting;

  factory PriceSetting.empty() => PriceSetting(dayGroups: [DayGroup.empty()]);

  /// 공휴일 요금을 따로 정했는지 여부. 없으면 공휴일 여부가 가격에 영향을 주지 않는다.
  bool get hasHolidayDayGroup =>
      dayGroups.any((g) => g.days.contains(Weekday.holiday));

  /// 예약 시간 및 인원 기반 기본 요금 계산 — [breakdownPrice]의 합계.
  ///
  /// 계산 규칙은 [breakdownPrice] 한 곳에만 둔다. 내역과 합계를 따로 계산하면
  /// 화면의 계산 내역과 저장되는 요금이 어긋날 수 있기 때문이다.
  ///
  /// [isHoliday]는 날짜별 공휴일 여부를 판단하는 콜백이다. 다일(allDay) 예약은
  /// 날짜마다 다른 결과를 받을 수 있어야 하므로 단일 `bool`이 아닌 함수로 받는다.
  /// 생략 시 모든 날짜를 공휴일이 아닌 것으로 처리한다.
  int calculatePrice({
    required DateTime start,
    required DateTime end,
    required int headCount,
    bool isAllDay = false,
    bool Function(DateTime date)? isHoliday,
  }) => breakdownPrice(
    start: start,
    end: end,
    headCount: headCount,
    isAllDay: isAllDay,
    isHoliday: isHoliday,
  ).total;

  /// 요금 계산 내역. 인자는 [calculatePrice]와 같다.
  PriceBreakdown breakdownPrice({
    required DateTime start,
    required DateTime end,
    required int headCount,
    bool isAllDay = false,
    bool Function(DateTime date)? isHoliday,
  }) {
    final holidayChecker = isHoliday ?? (_) => false;
    if (isAllDay) {
      return PriceBreakdown(
        days: [
          for (final date in pricedDatesOf(
            start: start,
            end: end,
            isAllDay: true,
          ))
            _allDayOf(date, headCount, isHoliday: holidayChecker(date)),
        ],
      );
    }
    final date = DateTime(start.year, start.month, start.day);
    final group = _dayGroupFor(date, isHoliday: holidayChecker(date));
    final startMinutes = start.hour * 60 + start.minute;
    final rawEndMinutes = end.hour * 60 + end.minute;
    final endMinutes = rawEndMinutes == 0 ? 1440 : rawEndMinutes;

    final items = <SlotCharge>[];
    for (final slot in group?.timeSlots ?? const <TimeSlot>[]) {
      if (slot.isAllDay) continue;
      final slotEnd = slot.endTime == 0 ? 1440 : slot.endTime;
      final overlapStart = max(startMinutes, slot.startTime);
      final overlapEnd = min(endMinutes, slotEnd);
      if (overlapStart >= overlapEnd) continue;
      final overlapHours = (overlapEnd - overlapStart) / 60.0;
      int amount = slot.isHourly
          ? (slot.price * overlapHours).round()
          : slot.price;
      if (slot.isPerPerson) amount *= headCount;
      items.add(
        SlotCharge(
          startMinute: overlapStart,
          endMinute: overlapEnd,
          unitPrice: slot.price,
          isHourly: slot.isHourly,
          perPersonCount: slot.isPerPerson ? headCount : null,
          amount: amount,
        ),
      );
    }
    // 인원 추가 요금은 슬롯이 하나라도 걸렸을 때만, 빈 시간까지 포함한 예약 시간 기준으로 받는다
    final headcount = group == null || items.isEmpty
        ? null
        : _headcountCharge(
            group.headcountRule,
            headCount,
            minutes: endMinutes - startMinutes,
          );
    return PriceBreakdown(
      days: [
        PricedDay(
          date: date,
          holidayRateApplied: _appliesHolidayRate(
            group,
            isHoliday: holidayChecker(date),
          ),
          items: [
            ..._withUnpricedGaps(items, startMinutes, endMinutes),
            ?headcount,
          ],
        ),
      ],
    );
  }

  /// 하루종일 예약의 [date] 하루 내역. 하루종일 슬롯은 00:00~24:00 기준이다.
  PricedDay _allDayOf(DateTime date, int headCount, {required bool isHoliday}) {
    final group = _dayGroupFor(date, isHoliday: isHoliday);
    final slot = group?.timeSlots.where((s) => s.isAllDay).firstOrNull;
    if (group == null || slot == null) {
      return PricedDay(
        date: date,
        holidayRateApplied: _appliesHolidayRate(group, isHoliday: isHoliday),
        items: const [PriceItem.unpriced(startMinute: 0, endMinute: 1440)],
      );
    }
    int amount = slot.isHourly ? (slot.price * 24).round() : slot.price;
    if (slot.isPerPerson) amount *= headCount;
    final headcount = _headcountCharge(
      group.headcountRule,
      headCount,
      minutes: 1440,
    );
    return PricedDay(
      date: date,
      holidayRateApplied: _appliesHolidayRate(group, isHoliday: isHoliday),
      items: [
        SlotCharge(
          startMinute: 0,
          endMinute: 1440,
          unitPrice: slot.price,
          isHourly: slot.isHourly,
          perPersonCount: slot.isPerPerson ? headCount : null,
          amount: amount,
        ),
        ?headcount,
      ],
    );
  }

  /// 공휴일인 날짜에 [group]으로 공휴일 요일 그룹을 적용했는지 여부.
  ///
  /// 토·일·공휴일처럼 공휴일이 다른 요일과 함께 묶인 그룹은 공휴일이 아닌 날에도 쓰이므로
  /// 그룹만으로 판단하지 않는다.
  static bool _appliesHolidayRate(DayGroup? group, {required bool isHoliday}) =>
      isHoliday && (group?.days.contains(Weekday.holiday) ?? false);

  /// [headCount]가 기준 인원을 넘을 때의 인원 추가 요금. 받을 요금이 없으면 null.
  ///
  /// [minutes]는 시간당 요금일 때 곱할 시간(분)이다.
  static HeadcountCharge? _headcountCharge(
    HeadcountRule rule,
    int headCount, {
    required int minutes,
  }) {
    final extraPeople = max(0, headCount - rule.headcountBase);
    if (extraPeople == 0 || rule.headcountExtraPrice == 0) return null;
    int amount = rule.headcountExtraPrice;
    if (rule.isHeadcountPerPerson) amount *= extraPeople;
    if (rule.isHeadcountHourly) amount = (amount * minutes / 60.0).round();
    return HeadcountCharge(
      headcountBase: rule.headcountBase,
      extraPeople: extraPeople,
      unitPrice: rule.headcountExtraPrice,
      isPerPerson: rule.isHeadcountPerPerson,
      minutes: rule.isHeadcountHourly ? minutes : null,
      amount: amount,
    );
  }

  /// [slots] 사이와 앞뒤의 빈 시간대를 [UnpricedRange]로 채워 시간 순서로 반환한다.
  ///
  /// 슬롯끼리 겹치면 각각 요금을 받으므로(계산 규칙 그대로) 빈 시간대는 슬롯 구간의
  /// 합집합 바깥만 센다.
  static List<PriceItem> _withUnpricedGaps(
    List<SlotCharge> slots,
    int startMinute,
    int endMinute,
  ) {
    final sorted = [...slots]
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final items = <PriceItem>[];
    var cursor = startMinute;
    for (final slot in sorted) {
      if (slot.startMinute > cursor) {
        items.add(
          PriceItem.unpriced(startMinute: cursor, endMinute: slot.startMinute),
        );
      }
      items.add(slot);
      cursor = max(cursor, slot.endMinute);
    }
    if (cursor < endMinute) {
      items.add(PriceItem.unpriced(startMinute: cursor, endMinute: endMinute));
    }
    return items;
  }

  /// [date]에 적용할 DayGroup.
  ///
  /// 공휴일이면 공휴일 DayGroup을 우선 쓰고, 공휴일이 어느 DayGroup에도 없으면
  /// 그 날짜의 실제 요일 DayGroup으로 대체한다. 공휴일 요금을 따로 정하지 않은
  /// 점포는 공휴일에도 평소 요금을 받는다는 뜻이기 때문이다.
  DayGroup? _dayGroupFor(DateTime date, {required bool isHoliday}) {
    DayGroup? groupOf(Weekday weekday) =>
        dayGroups.where((g) => g.days.contains(weekday)).firstOrNull;

    final weekdayGroup = groupOf(
      Weekday.values.firstWhere(
        (w) =>
            w.index + 1 ==
            date.weekday, // Weekday.monday.index = 0, weekday = 1
        orElse: () => Weekday.monday,
      ),
    );
    if (!isHoliday) return weekdayGroup;
    return groupOf(Weekday.holiday) ?? weekdayGroup;
  }
}
