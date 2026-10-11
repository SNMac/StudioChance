import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
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

@freezed
abstract class PriceSetting with _$PriceSetting {
  const PriceSetting._();

  const factory PriceSetting({required List<DayGroup> dayGroups}) =
      _PriceSetting;

  factory PriceSetting.empty() => PriceSetting(dayGroups: [DayGroup.empty()]);

  /// 공휴일 요금을 따로 정했는지 여부. 없으면 공휴일 여부가 가격에 영향을 주지 않는다.
  bool get hasHolidayDayGroup =>
      dayGroups.any((g) => g.days.contains(Weekday.holiday));

  /// 예약 시간 및 인원 기반 기본 요금 계산.
  ///
  /// 예약 구간과 겹치는 모든 TimeSlot을 순회하여 겹치는 시간만큼 각각 계산 후 합산.
  /// DayGroup/TimeSlot이 매칭되지 않으면 0 반환.
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
  }) {
    final holidayChecker = isHoliday ?? (_) => false;

    // 1. 하루종일 예약: 날짜별로 DayGroup을 찾아 합산
    //    - isHourly=false 다일 예약 시 일 수 반영
    //    - 날짜 경계를 넘는 다일 예약 시 각 날짜의 DayGroup 적용
    if (isAllDay) {
      int totalPrice = 0;
      bool anyMatched = false;

      for (final dayDate in pricedDatesOf(
        start: start,
        end: end,
        isAllDay: true,
      )) {
        final dayGroup = _dayGroupFor(
          dayDate,
          isHoliday: holidayChecker(dayDate),
        );
        if (dayGroup == null) continue;

        final slot = dayGroup.timeSlots.where((s) => s.isAllDay).firstOrNull;
        if (slot == null) continue;

        anyMatched = true;

        // 하루종일 슬롯은 00:00~24:00 기준이므로 24시간 고정
        int dayBase = slot.isHourly ? (slot.price * 24).round() : slot.price;
        if (slot.isPerPerson) dayBase *= headCount;

        final rule = dayGroup.headcountRule;
        final extraPeople = max(0, headCount - rule.headcountBase);
        int dayExtra = 0;
        if (extraPeople > 0) {
          dayExtra = rule.headcountExtraPrice;
          if (rule.isHeadcountPerPerson) dayExtra *= extraPeople;
          if (rule.isHeadcountHourly) dayExtra = (dayExtra * 24).round();
        }

        totalPrice += dayBase + dayExtra;
      }

      return anyMatched ? totalPrice : 0;
    }

    // 2. 시간 지정 예약: 예약 시작 날짜의 DayGroup 탐색
    final group = _dayGroupFor(start, isHoliday: holidayChecker(start));
    if (group == null) return 0;

    final totalHours = end.difference(start).inMinutes / 60.0;
    final startMinutes = start.hour * 60 + start.minute;
    final rawEndMinutes = end.hour * 60 + end.minute;
    // 끝 시간 00:00은 자정(1440분)으로 처리
    final endMinutes = rawEndMinutes == 0 ? 1440 : rawEndMinutes;

    int totalBase = 0;
    bool anyMatched = false;

    // 3. 겹치는 모든 TimeSlot의 기본 요금 합산
    for (final slot in group.timeSlots) {
      if (slot.isAllDay) continue;
      // 저장된 endTime 0은 하위 호환을 위해 1440으로 처리
      final slotEnd = slot.endTime == 0 ? 1440 : slot.endTime;
      final overlapStart = max(startMinutes, slot.startTime);
      final overlapEnd = min(endMinutes, slotEnd);
      if (overlapStart >= overlapEnd) continue;

      anyMatched = true;
      final overlapHours = (overlapEnd - overlapStart) / 60.0;
      int slotPrice = slot.isHourly
          ? (slot.price * overlapHours).round()
          : slot.price;
      if (slot.isPerPerson) slotPrice *= headCount;
      totalBase += slotPrice;
    }

    if (!anyMatched) return 0;

    // 4. 인원 추가 요금 계산 (전체 예약 시간 기준)
    final rule = group.headcountRule;
    final extraPeople = max(0, headCount - rule.headcountBase);
    int extraCharge = 0;
    if (extraPeople > 0) {
      extraCharge = rule.headcountExtraPrice;
      if (rule.isHeadcountPerPerson) extraCharge *= extraPeople;
      if (rule.isHeadcountHourly)
        extraCharge = (extraCharge * totalHours).round();
    }

    return totalBase + extraCharge;
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
