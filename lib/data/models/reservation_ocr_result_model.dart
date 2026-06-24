import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/domain/entities/reservation_ocr_result.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';

part 'reservation_ocr_result_model.freezed.dart';
part 'reservation_ocr_result_model.g.dart';

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

ReservationPlatform? _parsePlatform(Object? raw) {
  if (raw == null) return null;
  return switch (raw.toString().toUpperCase()) {
    'NAVER' => ReservationPlatform.naver,
    'SPACECLOUD' => ReservationPlatform.spaceCloud,
    'YANOLJA' => ReservationPlatform.yanolja,
    _ => ReservationPlatform.other,
  };
}

@freezed
abstract class ReservationOcrResultModel with _$ReservationOcrResultModel {
  const ReservationOcrResultModel._();

  const factory ReservationOcrResultModel({
    @JsonKey(name: 'platform', fromJson: _parsePlatform)
    ReservationPlatform? platform,
    String? customerName,
    String? customerPhone,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? startTime,
    @JsonKey(fromJson: _parseDateTimeNullable) DateTime? endTime,
    bool? isAllDay,
    int? headCount,
    String? memo,
    String? storeName,
    String? spaceName,
  }) = _ReservationOcrResultModel;

  factory ReservationOcrResultModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationOcrResultModelFromJson(json);

  ReservationOcrResult toEntity() {
    return ReservationOcrResult(
      platform: platform,
      customerName: customerName,
      customerPhone: customerPhone,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      headCount: headCount,
      memo: memo,
      storeName: storeName,
      spaceName: spaceName,
    );
  }
}
