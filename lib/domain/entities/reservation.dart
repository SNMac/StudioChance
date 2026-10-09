import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/price_setting.dart';
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

    /// 가격 계산에 쓴 요금표 스냅샷.
    ///
    /// 예약 수정 시 점포의 현재 요금이 아니라 이 요금표로 재계산하므로, 점포 요금이
    /// 바뀌어도 예약 가격이 저절로 바뀌지 않는다. null이면 스냅샷이 없는 예약
    /// (점포에 공간이 없었거나 스냅샷 도입 전 예약)이다.
    PriceSetting? priceSetting,
    DateTime? createdAt,
  }) = _Reservation;
}
