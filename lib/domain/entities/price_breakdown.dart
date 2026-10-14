import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_breakdown.freezed.dart';

/// 요금 계산 내역 — 계산 요금을 날짜별 시간대 요금과 인원 추가 요금 항목으로 나눈 것.
///
/// [PriceSetting.calculatePrice]는 이 내역의 [total]을 반환하므로 항목 금액의 합은
/// 항상 계산 요금과 같다.
@freezed
abstract class PriceBreakdown with _$PriceBreakdown {
  const PriceBreakdown._();

  const factory PriceBreakdown({required List<PricedDay> days}) =
      _PriceBreakdown;

  int get total => days.fold(0, (sum, day) => sum + day.subtotal);

  /// 요금 설정이 없어 0원으로 계산된 시간대가 있는지 — 요금표를 채워야 한다는 신호다
  bool get hasUnpricedRange =>
      days.any((day) => day.items.any((item) => item is UnpricedRange));
}

/// 요금 계산 내역의 한 날짜.
@freezed
abstract class PricedDay with _$PricedDay {
  const PricedDay._();

  const factory PricedDay({
    required DateTime date,

    /// 공휴일 요일 그룹의 요금을 적용했는지 여부. 공휴일이어도 공휴일 요일 그룹이 없어
    /// 실제 요일 요금을 받았으면 false다.
    required bool holidayRateApplied,
    required List<PriceItem> items,
  }) = _PricedDay;

  int get subtotal => items.fold(0, (sum, item) => sum + item.amount);
}

/// 요금 계산 내역의 항목. 시간대는 그 날짜 00:00부터의 분이다.
@freezed
sealed class PriceItem with _$PriceItem {
  const PriceItem._();

  /// 시간대 요금. [perPersonCount]는 1인당 요금일 때 곱한 인원 수다.
  const factory PriceItem.slot({
    required int startMinute,
    required int endMinute,
    required int unitPrice,
    required bool isHourly,
    int? perPersonCount,
    required int amount,
  }) = SlotCharge;

  /// 인원 추가 요금. [minutes]는 시간당 요금일 때 곱한 시간(분)이고, 1회 요금이면 null이다.
  const factory PriceItem.headcount({
    required int headcountBase,
    required int extraPeople,
    required int unitPrice,
    required bool isPerPerson,
    int? minutes,
    required int amount,
  }) = HeadcountCharge;

  /// 요금 설정이 없는 시간대. 요일 그룹이나 슬롯이 없어 0원으로 계산된다.
  const factory PriceItem.unpriced({
    required int startMinute,
    required int endMinute,
  }) = UnpricedRange;

  int get amount => switch (this) {
    SlotCharge(:final amount) => amount,
    HeadcountCharge(:final amount) => amount,
    UnpricedRange() => 0,
  };
}
