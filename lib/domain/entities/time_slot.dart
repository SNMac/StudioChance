import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_slot.freezed.dart';
part 'time_slot.g.dart';

@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required int startTime,
    required int endTime,
    required int price,
    required bool isHourly,
    required bool isPerPerson,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
}
