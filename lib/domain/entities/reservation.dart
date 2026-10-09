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

extension ReservationPriceSnapshot on Reservation {
  /// 이 예약(저장된 상태)의 요금표를 [edited]의 가격 계산에 그대로 쓸 수 있는지 여부.
  ///
  /// 저장된 요금표가 있고 점포·공간이 같을 때만 유지한다. 점포·공간이 바뀌면 저장된
  /// 요금표는 다른 공간의 것이므로 현재 요금표를 써야 한다. 점포는 표시 정보(이름·색상)가
  /// 아닌 id로 비교한다.
  ///
  /// 예약 수정 UseCase와 상세 모달이 이 규칙을 공유해야 화면 가격과 저장 가격이 일치한다.
  bool keepsPriceSettingFor(Reservation edited) {
    return priceSetting != null &&
        storeSummary.id == edited.storeSummary.id &&
        spaceOptionId == edited.spaceOptionId;
  }
}
