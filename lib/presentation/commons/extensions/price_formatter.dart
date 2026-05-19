import 'package:flutter/services.dart';

extension IntPriceFormatter on int {
  /// 천 단위 쉼표 + '원' 접미사 (읽기 전용 표시용)
  /// 예: 30000 → "30,000원", -2000 → "-2,000원"
  String get formattedPrice {
    final isNegative = this < 0;
    final withCommas = _addCommas(abs().toString());
    return '${isNegative ? '-' : ''}$withCommas원';
  }

  /// 천 단위 쉼표만 추가 (텍스트 필드 초기값용)
  /// 예: 30000 → "30,000", -2000 → "-2,000"
  String get formattedAmount {
    final isNegative = this < 0;
    final withCommas = _addCommas(abs().toString());
    return '${isNegative ? '-' : ''}$withCommas';
  }
}

String _addCommas(String digits) {
  return digits.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

/// 금액 입력 시 천 단위 쉼표 자동 포맷터
class PriceInputFormatter extends TextInputFormatter {
  const PriceInputFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;

    final isNegative = allowNegative && raw.startsWith('-');
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      if (isNegative) {
        return const TextEditingValue(
          text: '-',
          selection: TextSelection.collapsed(offset: 1),
        );
      }
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final result = isNegative ? '-${_addCommas(digits)}' : _addCommas(digits);
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
