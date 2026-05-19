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
  /// 예약 구간과 겹치는 모든 TimeSlot을 순회하여 겹치는 시간만큼 각각 계산 후 합산.
  /// DayGroup/TimeSlot이 매칭되지 않으면 0 반환.
  int calculatePrice({
    required DateTime start,
    required DateTime end,
    required int headCount,
    bool isAllDay = false,
    bool isHoliday = false,
  }) {
    // 1. 예약 요일에 맞는 DayGroup 탐색
    // isHoliday=true이면 Weekday.holiday 그룹 우선 적용 (공휴일 감지는 호출부 책임)
    final weekday = isHoliday
        ? Weekday.holiday
        : Weekday.values.firstWhere(
            (w) => w.index + 1 == start.weekday, // Weekday.monday.index = 0, weekday = 1
            orElse: () => Weekday.monday,
          );

    final group = dayGroups.where((g) => g.days.contains(weekday)).firstOrNull;
    if (group == null) return 0;

    final totalHours = end.difference(start).inMinutes / 60.0;

    // 2. 하루종일 예약: isAllDay 슬롯 단일 매칭
    if (isAllDay) {
      final slot = group.timeSlots.where((s) => s.isAllDay).firstOrNull;
      if (slot == null) return 0;
      int basePrice = slot.isHourly ? (slot.price * totalHours).round() : slot.price;
      if (slot.isPerPerson) basePrice *= headCount;

      final rule = group.headcountRule;
      final extraPeople = max(0, headCount - rule.headcountBase);
      int extraCharge = 0;
      if (extraPeople > 0) {
        extraCharge = rule.headcountExtraPrice * extraPeople;
        if (rule.isHeadcountHourly) extraCharge = (extraCharge * totalHours).round();
      }
      return basePrice + extraCharge;
    }

    // 3. 시간 지정 예약: 겹치는 모든 TimeSlot의 기본 요금 합산
    final startMinutes = start.hour * 60 + start.minute;
    final rawEndMinutes = end.hour * 60 + end.minute;
    // 끝 시간 00:00은 자정(1440분)으로 처리
    final endMinutes = rawEndMinutes == 0 ? 1440 : rawEndMinutes;

    int totalBase = 0;
    bool anyMatched = false;

    for (final slot in group.timeSlots) {
      if (slot.isAllDay) continue;
      // 저장된 endTime 0은 하위 호환을 위해 1440으로 처리
      final slotEnd = slot.endTime == 0 ? 1440 : slot.endTime;
      final overlapStart = max(startMinutes, slot.startTime);
      final overlapEnd = min(endMinutes, slotEnd);
      if (overlapStart >= overlapEnd) continue;

      anyMatched = true;
      final overlapHours = (overlapEnd - overlapStart) / 60.0;
      int slotPrice = slot.isHourly ? (slot.price * overlapHours).round() : slot.price;
      if (slot.isPerPerson) slotPrice *= headCount;
      totalBase += slotPrice;
    }

    if (!anyMatched) return 0;

    // 4. 인원 추가 요금 계산 (전체 예약 시간 기준)
    final rule = group.headcountRule;
    final extraPeople = max(0, headCount - rule.headcountBase);
    int extraCharge = 0;
    if (extraPeople > 0) {
      extraCharge = rule.headcountExtraPrice * extraPeople;
      if (rule.isHeadcountHourly) extraCharge = (extraCharge * totalHours).round();
    }

    return totalBase + extraCharge;
  }
}
