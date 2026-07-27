import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/headcount_rule_model.dart';
import 'package:studio_chance/data/models/time_slot_model.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/time_slot.dart';
import 'package:studio_chance/common/enums/weekday.dart';

part 'day_group_model.freezed.dart';
part 'day_group_model.g.dart';

@freezed
abstract class DayGroupModel with _$DayGroupModel {
  const DayGroupModel._();

  const factory DayGroupModel({
    @Default([]) List<Weekday> days,
    required HeadcountRuleModel headcountRuleModel,
    @Default([]) List<TimeSlotModel> timeSlots,
  }) = _DayGroupModel;

  factory DayGroupModel.fromJson(Map<String, dynamic> json) =>
      _$DayGroupModelFromJson(json);

  factory DayGroupModel.fromEntity(DayGroup entity) {
    return DayGroupModel(
      days: entity.days,
      headcountRuleModel: HeadcountRuleModel.fromEntity(entity.headcountRule),
      timeSlots: entity.timeSlots
          .map((timeSlot) => TimeSlotModel.fromEntity(timeSlot))
          .toList(),
    );
  }

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
