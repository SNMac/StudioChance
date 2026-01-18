import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';

part 'day_group.freezed.dart';

@freezed
abstract class DayGroup with _$DayGroup {
  const factory DayGroup({
    required List<int> days, // 1~7: 요일, 8: 공휴일
    required HeadcountRule headcountRule,
    required List<TimeSlot> timeSlots,
  }) = _DayGroup;

  factory DayGroup.empty() => const DayGroup(
    days: [], // 요일 선택 안 됨
    headcountRule: HeadcountRule(
      headcountBase: 0,
      headcountExtraPrice: 0,
      isHeadcountHourly: true,
      isHeadcountPerPerson: true,
    ),
    timeSlots: [], // 시간 설정 안 됨
  );
}
