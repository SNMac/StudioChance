import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_slot.freezed.dart';

@freezed
abstract class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    required int startTime,
    required int endTime,
    required int price,
    required bool isHourly,
    required bool isPerPerson,
  }) = _TimeSlot;

  factory TimeSlot.empty() => const TimeSlot(
    startTime: 360,
    endTime: 1080,
    price: -1,
    isHourly: true,
    isPerPerson: false,
  );
}
