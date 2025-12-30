import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/headcount_rule.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';

part 'day_group.freezed.dart';
part 'day_group.g.dart';

@freezed
abstract class DayGroup with _$DayGroup {
  const factory DayGroup({
    required List<int> days,
    required List<HeadcountRule> headcountRules,
    required List<TimeSlot> timeSlots,
  }) = _DayGroup;

  factory DayGroup.fromJson(Map<String, dynamic> json) => _$DayGroupFromJson(json);
}