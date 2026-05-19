import 'package:flutter/services.dart';

extension StringPhoneFormatter on String {
  /// 숫자만 추출 후 "앞3-중간-뒤4" 형식으로 변환
  /// 예: "01012345678" → "010-1234-5678", "0101234567" → "010-123-4567"
  String get formattedPhone {
    final digits = replaceAll(RegExp(r'[^0-9]'), '');
    return _formatPhoneDigits(digits);
  }
}

String _formatPhoneDigits(String digits) {
  if (digits.length <= 3) return digits;
  final first3 = digits.substring(0, 3);
  final rest = digits.substring(3);
  if (rest.length <= 4) return '$first3-$rest';
  final last4 = rest.substring(rest.length - 4);
  final middle = rest.substring(0, rest.length - 4);
  return '$first3-$middle-$last4';
}

/// 전화번호 입력 시 자동 하이픈 포맷터 (앞3-중간-뒤4 규칙, 최대 11자리)
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) return oldValue;
    final formatted = _formatPhoneDigits(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
