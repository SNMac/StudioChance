import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';

part 'reservation_summary.freezed.dart';

@freezed
abstract class ReservationSummary with _$ReservationSummary {
  const factory ReservationSummary({
    required String id,
    required StoreSummary storeSummary,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required bool isAllDay,
    required DateTime startTime,
    required DateTime endTime,
  }) = _ReservationSummary;
}
