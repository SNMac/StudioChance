import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';

part 'reservation_ocr_result.freezed.dart';

@freezed
abstract class ReservationOcrResult with _$ReservationOcrResult {
  const factory ReservationOcrResult({
    ReservationPlatform? platform,
    String? customerName,
    String? customerPhone,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    int? headCount,
    String? memo,
  }) = _ReservationOcrResult;
}
