import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/constants/data_constants.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/domain/enums/weekday.dart';

part 'day_group.freezed.dart';

@freezed
abstract class DayGroup with _$DayGroup {
  const factory DayGroup({
    required List<Weekday> days,
    required HeadcountRule headcountRule,
    required List<TimeSlot> timeSlots,
  }) = _DayGroup;

  factory DayGroup.empty() => DayGroup(
    days: [],
    headcountRule: HeadcountRule(
      headcountBase: emptyValue,
      headcountExtraPrice: emptyValue,
      isHeadcountHourly: true,
      isHeadcountPerPerson: true,
    ),
    timeSlots: [TimeSlot.empty()],
  );
}
