import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ReservationStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('CANCELED')
  canceled;

  String get displayName => switch (this) {
    ReservationStatus.pending => '입금 대기',
    ReservationStatus.confirmed => '예약 확정',
    ReservationStatus.canceled => '예약 취소',
  };

  String get jsonValue => switch (this) {
    ReservationStatus.pending => 'PENDING',
    ReservationStatus.confirmed => 'CONFIRMED',
    ReservationStatus.canceled => 'CANCELED',
  };
}
