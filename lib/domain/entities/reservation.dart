import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/domain/entities/holiday_calendar.dart';
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

    /// 가격 계산 때 공휴일로 판정한 날짜들의 스냅샷 (`yyyy-MM-dd`).
    ///
    /// 공휴일 달력이 바뀌어도(임시공휴일 지정, 예측 공휴일 교체) 예약 가격이 저절로
    /// 바뀌지 않게 한다 (ADR-0003). 판정한 날짜 범위는 이 예약의 [pricedDatesOf]이므로
    /// 공휴일이 아닌 날짜는 담지 않는다. null이면 스냅샷이 없는 예약이다.
    List<String>? holidayDates,
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

  /// 이 예약(저장된 상태)을 [edited]로 수정할 때 쓸 날짜별 공휴일 판정.
  ///
  /// 요금표를 유지하는 수정([keepsPriceSettingFor])이면 이 예약이 판정했던 날짜는
  /// 공휴일 스냅샷을 따르고, 그 밖의 날짜(날짜를 옮긴 경우)는 [current]를 따른다.
  /// 요금표를 유지하지 않거나 스냅샷이 없으면 모든 날짜를 [current]로 판정한다.
  /// [current]가 모르는 연도는 공휴일이 아닌 것으로 본다.
  bool Function(DateTime date) holidayCheckerFor(
    Reservation edited,
    HolidayCalendar current,
  ) {
    bool currentChecker(DateTime date) => current.isHoliday(date) ?? false;

    final snapshot = holidayDates;
    if (snapshot == null || !keepsPriceSettingFor(edited)) {
      return currentChecker;
    }

    final judgedKeys = pricedDatesOf(
      start: startTime,
      end: endTime,
      isAllDay: isAllDay,
    ).map(holidayDateKey).toSet();
    return (date) {
      final key = holidayDateKey(date);
      return judgedKeys.contains(key)
          ? snapshot.contains(key)
          : currentChecker(date);
    };
  }

  /// [isHoliday]로 판정했을 때 이 예약의 공휴일 스냅샷 — 공휴일인 날짜 키만 담는다.
  List<String> holidayDatesWith(bool Function(DateTime date) isHoliday) {
    return pricedDatesOf(start: startTime, end: endTime, isAllDay: isAllDay)
        .where(isHoliday)
        .map(holidayDateKey)
        .toList();
  }

  /// [edited]로 수정할 때 공휴일 스냅샷을 따르는 날짜 중 [current]와 판정이 다른 날짜가
  /// 있는지 여부. '현재 요금 적용'을 제안할지 판단하는 데 쓴다.
  ///
  /// 스냅샷을 따르지 않는 수정이면 어차피 [current]로 계산하므로 false다.
  /// [current]가 모르는 연도의 날짜는 비교하지 않는다.
  bool holidaysDifferFromCurrent(Reservation edited, HolidayCalendar current) {
    final snapshot = holidayDates;
    if (snapshot == null || !keepsPriceSettingFor(edited)) return false;

    final judgedKeys = pricedDatesOf(
      start: startTime,
      end: endTime,
      isAllDay: isAllDay,
    ).map(holidayDateKey).toSet();
    return pricedDatesOf(
      start: edited.startTime,
      end: edited.endTime,
      isAllDay: edited.isAllDay,
    ).any((date) {
      final key = holidayDateKey(date);
      final currentJudgement = current.isHoliday(date);
      return judgedKeys.contains(key) &&
          currentJudgement != null &&
          currentJudgement != snapshot.contains(key);
    });
  }
}
