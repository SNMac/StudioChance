import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/enums/weekday.dart';

part 'price_setting.freezed.dart';

@freezed
abstract class PriceSetting with _$PriceSetting {
  const PriceSetting._();

  const factory PriceSetting({required List<DayGroup> dayGroups}) =
      _PriceSetting;

  factory PriceSetting.empty() => PriceSetting(dayGroups: [DayGroup.empty()]);

  /// 예약 시간 및 인원 기반 기본 요금 계산.
  ///
  /// DayGroup/TimeSlot이 매칭되지 않으면 0 반환.
  int calculatePrice({
    required DateTime start,
    required DateTime end,
    required int headCount,
    bool isAllDay = false,
  }) {
    // 1. 예약 요일에 맞는 DayGroup 탐색
    final weekday = Weekday.values.firstWhere(
      (w) => w.index + 1 == start.weekday, // Weekday.monday.index = 0, weekday = 1
      orElse: () => Weekday.monday,
    );

    final group = dayGroups.where((g) => g.days.contains(weekday)).firstOrNull;
    if (group == null) return 0;

    // 2. TimeSlot 탐색
    final startMinutes = start.hour * 60 + start.minute;
    final slot = isAllDay
        ? group.timeSlots.where((s) => s.isAllDay).firstOrNull
        : group.timeSlots
              .where(
                (s) =>
                    !s.isAllDay &&
                    s.startTime <= startMinutes &&
                    startMinutes < s.endTime,
              )
              .firstOrNull;
    if (slot == null) return 0;

    // 3. 기본 요금 계산
    final hours = end.difference(start).inMinutes / 60.0;
    int basePrice = slot.isHourly ? (slot.price * hours).round() : slot.price;
    if (slot.isPerPerson) basePrice *= headCount;

    // 4. 인원 추가 요금 계산
    final rule = group.headcountRule;
    final extraPeople = max(0, headCount - rule.headcountBase);
    int extraCharge = 0;
    if (extraPeople > 0) {
      extraCharge = rule.headcountExtraPrice * extraPeople;
      if (rule.isHeadcountHourly) extraCharge = (extraCharge * hours).round();
    }

    return basePrice + extraCharge;
  }
}
