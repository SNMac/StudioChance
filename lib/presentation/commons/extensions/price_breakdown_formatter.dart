import 'package:studio_chance/domain/entities/price_breakdown.dart';
import 'package:studio_chance/presentation/commons/extensions/price_formatter.dart';

/// 요금 계산 내역 항목의 표시 문구.
extension PriceItemFormatter on PriceItem {
  /// 항목 제목. 시간대 항목은 "10:00 – 12:00", 하루 전체면 "하루종일"이다.
  String get title => switch (this) {
    SlotCharge(:final startMinute, :final endMinute) => _rangeTitle(
      startMinute,
      endMinute,
    ),
    HeadcountCharge() => '인원 추가',
    UnpricedRange(:final startMinute, :final endMinute) => _rangeTitle(
      startMinute,
      endMinute,
    ),
  };

  /// 금액이 나온 산식. 예: "10,000원 × 2시간"
  String get formula => switch (this) {
    SlotCharge(
      :final unitPrice,
      :final perPersonCount,
      :final isHourly,
      :final startMinute,
      :final endMinute,
    ) =>
      _joinFactors([
        unitPrice.formattedPrice,
        if (perPersonCount != null) '$perPersonCount명',
        if (isHourly) _duration(endMinute - startMinute),
      ]),
    final HeadcountCharge charge => _headcountFormula(charge),
    UnpricedRange() => '요금 설정 없음',
  };
}

/// 예: "기준 4명 초과 2명 × 3,000원 × 5시간", "기준 4명 초과 · 1회 요금"
String _headcountFormula(HeadcountCharge charge) {
  final minutes = charge.minutes;
  final rate = [
    charge.unitPrice.formattedPrice,
    if (minutes != null) _duration(minutes),
  ];
  final base = '기준 ${charge.headcountBase}명 초과';
  // 1인당이 아니면 초과 인원 수와 무관한 금액이므로 인원 수를 곱하지 않는다
  if (!charge.isPerPerson) return '$base · ${_joinFactors(rate)}';
  return '$base ${['${charge.extraPeople}명', ...rate].join(' × ')}';
}

/// 곱한 요소가 단가 하나뿐이면 고정 요금이므로 "1회 요금"으로 표시한다.
String _joinFactors(List<String> factors) =>
    factors.length == 1 ? '1회 요금' : factors.join(' × ');

String _rangeTitle(int startMinute, int endMinute) {
  if (startMinute == 0 && endMinute == 1440) return '하루종일';
  return '${_clock(startMinute)} – ${_clock(endMinute)}';
}

/// 분을 "HH:mm"으로. 날짜 끝(1440)은 "24:00"으로 표시해 시작 시각 00:00과 구분한다.
String _clock(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:'
    '${(minute % 60).toString().padLeft(2, '0')}';

/// 분을 "2시간 5분", "30분", "3시간"으로.
String _duration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '$rest분';
  if (rest == 0) return '$hours시간';
  return '$hours시간 $rest분';
}
