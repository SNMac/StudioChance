import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_member_info.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/enums/payment_method.dart';
import 'package:studio_chance/domain/enums/reservation_platform.dart';
import 'package:studio_chance/domain/enums/reservation_status.dart';
import 'package:studio_chance/domain/enums/user_role.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

@freezed
abstract class ReservationModel with _$ReservationModel {
  const ReservationModel._();

  const factory ReservationModel({
    @JsonKey(includeToJson: false) required String id,
    required String storeId,
    required String writerId,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required String memo,
    required bool isAllDay,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,
    required ReservationPlatform platform,
    required PaymentMethod paymentMethod,
    required int calculatedPrice,
    required int priceAdjustment,
    required int totalPrice,
    required UserRole writerRole,
    String? spaceOptionId,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);

  factory ReservationModel.fromEntity(Reservation entity) {
    return ReservationModel(
      id: entity.id,
      storeId: entity.storeSummary.id,
      writerId: entity.writer.user.id,
      status: entity.status,
      customerName: entity.customerName,
      headCount: entity.headCount,
      customerPhone: entity.customerPhone,
      memo: entity.memo,
      isAllDay: entity.isAllDay,
      startTime: entity.startTime,
      endTime: entity.endTime,
      platform: entity.platform,
      paymentMethod: entity.paymentMethod,
      calculatedPrice: entity.calculatedPrice,
      priceAdjustment: entity.priceAdjustment,
      totalPrice: entity.totalPrice,
      writerRole: entity.writer.role,
      spaceOptionId: entity.spaceOptionId,
    );
  }

  /// 예약 수정 가능 필드만 반환 (allowlist 방식)
  /// - 새 불변 필드가 추가되어도 여기 명시하지 않는 한 자동으로 제외된다.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    const editableFields = {
      'status', 'customerName', 'headCount', 'customerPhone', 'memo',
      'isAllDay', 'startTime', 'endTime', 'platform', 'paymentMethod',
      'calculatedPrice', 'priceAdjustment', 'totalPrice', 'spaceOptionId',
    };
    return {
      for (final entry in json.entries)
        if (editableFields.contains(entry.key)) entry.key: entry.value,
    };
  }

  Reservation toEntity(StoreSummary storeSummary, StoreMemberInfo writer) {
    return Reservation(
      id: id,
      storeSummary: storeSummary,
      writer: writer,
      status: status,
      customerName: customerName,
      headCount: headCount,
      customerPhone: customerPhone,
      memo: memo,
      isAllDay: isAllDay,
      startTime: startTime,
      endTime: endTime,
      platform: platform,
      paymentMethod: paymentMethod,
      calculatedPrice: calculatedPrice,
      priceAdjustment: priceAdjustment,
      totalPrice: totalPrice,
      spaceOptionId: spaceOptionId,
    );
  }
}
