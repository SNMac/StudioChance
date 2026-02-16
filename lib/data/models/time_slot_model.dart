import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/time_slot.dart';

part 'time_slot_model.freezed.dart';
part 'time_slot_model.g.dart';

@freezed
abstract class TimeSlotModel with _$TimeSlotModel {
  const TimeSlotModel._();

  const factory TimeSlotModel({
    required bool isAllDay,
    required int startTime, // 분 단위
    required int endTime, // 분 단위
    required int price,
    required bool isHourly,
    required bool isPerPerson,
  }) = _TimeSlotModel;

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotModelFromJson(json);

  factory TimeSlotModel.fromEntity(TimeSlot entity) {
    return TimeSlotModel(
      isAllDay: entity.isAllDay,
      startTime: entity.startTime,
      endTime: entity.endTime,
      price: entity.price,
      isHourly: entity.isHourly,
      isPerPerson: entity.isPerPerson,
    );
  }

  TimeSlot toEntity() {
    return TimeSlot(
      isAllDay: isAllDay,
      startTime: startTime,
      endTime: endTime,
      price: price,
      isHourly: isHourly,
      isPerPerson: isPerPerson,
    );
  }
}
