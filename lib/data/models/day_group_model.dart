import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/headcount_rule_model.dart';
import 'package:studio_chance/data/models/time_slot_model.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';

part 'day_group_model.freezed.dart';
part 'day_group_model.g.dart';

@freezed
abstract class DayGroupModel with _$DayGroupModel {
  const factory DayGroupModel({
    @Default([]) List<int> days, // 1~7
    required HeadcountRuleModel headcountRuleModel,
    @Default([]) List<TimeSlotModel> timeSlots,
  }) = _DayGroupModel;

  factory DayGroupModel.fromJson(Map<String, dynamic> json) =>
      _$DayGroupModelFromJson(json);
}

extension DayGroupModelExtension on DayGroupModel {
  DayGroup toEntity() {
    return DayGroup(
      days: days,
      headcountRule: headcountRuleModel.toEntity(),
      timeSlots: timeSlots
          .map<TimeSlot>((timeSlotModel) => timeSlotModel.toEntity())
          .toList(),
    );
  }
}
