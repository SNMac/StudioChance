import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/common/enums/payment_method.dart';
import 'package:studio_chance/common/enums/reservation_platform.dart';
import 'package:studio_chance/common/enums/reservation_status.dart';

part 'reservation.freezed.dart';

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required StoreSummary storeSummary,
    required StoreMemberInfo writer,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required String memo,
    required bool isAllDay,
    required DateTime startTime,
    required DateTime endTime,
    required ReservationPlatform platform,
    required PaymentMethod paymentMethod,
    required int calculatedPrice,
    required int priceAdjustment,
    required int totalPrice,
    String? spaceOptionId,
  }) = _Reservation;
}
