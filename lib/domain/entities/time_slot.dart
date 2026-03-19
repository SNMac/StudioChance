import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/constants/data_constants.dart';

part 'time_slot.freezed.dart';

@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required bool isAllDay,
    required int startTime,
    required int endTime,
    required int price,
    required bool isHourly,
    required bool isPerPerson,
  }) = _TimeSlot;

  factory TimeSlot.empty() => const TimeSlot(
    isAllDay: false,
    startTime: 360,
    endTime: 1080,
    price: emptyValue,
    isHourly: true,
    isPerPerson: false,
  );
}
